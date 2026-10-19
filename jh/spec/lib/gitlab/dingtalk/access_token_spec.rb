# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::AccessToken, :use_clean_rails_memory_store_caching,
  feature_category: :integrations do
  subject(:fetch_token) { described_class.fetch(app_id: 'app', app_secret: 'secret') }

  let(:request) do
    stub_request(:post, described_class::ENDPOINT)
      .with(body: { appKey: 'app', appSecret: 'secret' }.to_json)
      .to_return(body: { accessToken: 'token-value', expireIn: 7200 }.to_json)
  end

  before do
    request
  end

  it 'fetches once and caches an encrypted token', :aggregate_failures do
    expect(Rails.cache).to receive(:write).with(anything, anything, expires_in: 6600)
      .and_wrap_original do |method, key, value, **options|
      expect(key).not_to include('secret')
      expect(value).not_to include('token-value')
      expect(Gitlab::CryptoHelper.aes256_gcm_decrypt(value)).to eq('token-value')
      method.call(key, value, **options)
    end

    expect(fetch_token).to eq('token-value')
    expect(described_class.fetch(app_id: 'app', app_secret: 'secret')).to eq('token-value')
    expect(request).to have_been_requested.once
  end

  it 'invalidates the token' do
    fetch_token
    described_class.invalidate(app_id: 'app', app_secret: 'secret')
    described_class.fetch(app_id: 'app', app_secret: 'secret')

    expect(request).to have_been_requested.twice
  end

  it 'does not bypass an occupied refresh lock', :aggregate_failures do
    allow_next_instance_of(Gitlab::ExclusiveLease) do |lease|
      allow(lease).to receive(:try_obtain).and_return(false)
      expect(lease).not_to receive(:cancel)
    end

    expect { fetch_token }.to raise_error(Gitlab::Dingtalk::AppResponse::TransientError)
    expect(request).not_to have_been_requested
  end

  it 'refreshes after the cache expires', :freeze_time do
    fetch_token
    travel 6601.seconds
    described_class.fetch(app_id: 'app', app_secret: 'secret')

    expect(request).to have_been_requested.twice
  end

  it 'uses a separate cache after secret rotation' do
    fetch_token
    other = stub_request(:post, described_class::ENDPOINT)
      .with(body: { appKey: 'app', appSecret: 'new-secret' }.to_json)
      .to_return(body: { accessToken: 'new-token', expireIn: 7200 }.to_json)

    expect(described_class.fetch(app_id: 'app', app_secret: 'new-secret')).to eq('new-token')
    expect(other).to have_been_requested.once
  end

  [{}, { accessToken: '', expireIn: 7200 }, { accessToken: 't', expireIn: 0 }].each do |body|
    it "rejects invalid token response #{body}" do
      stub_request(:post, described_class::ENDPOINT).to_return(body: body.to_json)

      expect { fetch_token }.to raise_error(Gitlab::Dingtalk::AppResponse::PermanentError)
    end
  end
end
