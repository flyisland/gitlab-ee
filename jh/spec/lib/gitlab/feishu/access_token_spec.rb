# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::AccessToken, :use_clean_rails_memory_store_caching,
  feature_category: :integrations do
  let(:app) { Gitlab::Feishu::App }
  let(:endpoint) { 'https://open.feishu.test/open-apis/auth/v3/tenant_access_token/internal' }
  let(:body) { { code: 0, tenant_access_token: 'tenant-token', expire: 7200 } }
  let(:key) do
    fingerprint = Gitlab::CryptoHelper.sha256(
      Gitlab::Json.generate(['https://open.feishu.test', 'tenant', 'cli_app', 'app-secret'])
    )
    "integration:feishu:#{fingerprint}:tenant_access_token"
  end

  subject(:fetch) { described_class.fetch }

  before do
    allow(app).to receive_messages(api_site: 'https://open.feishu.test', tenant_key: 'tenant',
      app_id: 'cli_app', app_secret: 'app-secret')
    stub_request(:post, endpoint).with(body: Gitlab::Json.generate(app_id: 'cli_app', app_secret: 'app-secret'))
      .to_return(status: 200, body: Gitlab::Json.generate(body))
  end

  it 'encrypts and reuses the cached token', :aggregate_failures do
    expect(fetch).to eq('tenant-token')
    expect(described_class.fetch).to eq('tenant-token')
    expect(a_request(:post, endpoint)).to have_been_made.once
    expect(Rails.cache.read(key)).not_to include('tenant-token', 'app-secret')
    expect(Gitlab::CryptoHelper.aes256_gcm_decrypt(Rails.cache.read(key))).to eq('tenant-token')
  end

  it 'expires before the provider token does' do
    expect(Rails.cache).to receive(:write).with(key, anything, expires_in: 7140)

    fetch
  end

  it 'invalidates the cache' do
    fetch
    described_class.invalidate
    described_class.fetch

    expect(a_request(:post, endpoint)).to have_been_made.twice
  end

  it 'isolates cache entries after changing the application or tenant' do
    fetch
    allow(app).to receive(:tenant_key).and_return('other-tenant')
    described_class.fetch

    expect(a_request(:post, endpoint)).to have_been_made.twice
  end

  it 'waits for another refresher and reuses its result' do
    allow_next_instance_of(Gitlab::ExclusiveLease) do |lease|
      allow(lease).to receive(:try_obtain).and_return(false)
      expect(lease).not_to receive(:cancel)
    end
    allow(described_class).to receive(:sleep) do
      Rails.cache.write(key, Gitlab::CryptoHelper.aes256_gcm_encrypt('other-token'), expires_in: 60)
    end

    expect(fetch).to eq('other-token')
    expect(a_request(:post, endpoint)).not_to have_been_made
  end

  it 'never bypasses a held lease with a concurrent token request' do
    allow_next_instance_of(Gitlab::ExclusiveLease) do |lease|
      allow(lease).to receive(:try_obtain).and_return(false)
      expect(lease).not_to receive(:cancel)
    end
    allow(described_class).to receive(:sleep)

    expect { fetch }.to raise_error(Gitlab::Feishu::AppResponse::TransientError)
    expect(a_request(:post, endpoint)).not_to have_been_made
  end

  [{}, { code: 0, expire: 7200 }, { code: 0, tenant_access_token: '', expire: 7200 },
    { code: 0, tenant_access_token: 'token', expire: 0 },
    { code: 0, tenant_access_token: 'token', expire: '7200' }].each do |invalid_body|
    context "with #{invalid_body.inspect}" do
      let(:body) { invalid_body }

      it 'does not cache an invalid token' do
        expect { fetch }.to raise_error(Gitlab::Feishu::AppResponse::PermanentError)
        expect(Rails.cache.read(key)).to be_nil
      end
    end
  end

  context 'when the token expires too soon to cache' do
    let(:body) { { code: 0, tenant_access_token: 'token', expire: 30 } }

    it 'returns the token without caching it' do
      expect(fetch).to eq('token')
      expect(Rails.cache.read(key)).to be_nil
    end
  end
end
