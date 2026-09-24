# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Wecom::AccessToken, :use_clean_rails_memory_store_caching,
  feature_category: :system_access do
  using RSpec::Parameterized::TableSyntax

  let(:corp_id) { 'ww1234567890abcdef' }
  let(:corp_secret) { 'corp-secret' }
  let(:token_url) { described_class::ENDPOINT }

  def stub_gettoken(body, status: 200)
    stub_request(:get, token_url)
      .with(query: { corpid: corp_id, corpsecret: corp_secret })
      .to_return(status: status, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def fetch(secret = corp_secret)
    described_class.fetch(corp_id: corp_id, corp_secret: secret)
  end

  def cache_key(secret = corp_secret)
    fingerprint = Gitlab::CryptoHelper.sha256(secret)[0, 16]

    "integration:wecom:#{corp_id}:#{fingerprint}:access_token"
  end

  describe '.fetch' do
    it 'returns the token and its lifetime' do
      stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 7200 })

      expect(fetch).to eq(['corp-token', 7200])
    end

    # WeCom issues one token per app, so a second request can invalidate the
    # token another part of the application still holds.
    it 'only calls WeCom once for repeated fetches' do
      request = stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 7200 })

      3.times { fetch }

      expect(request).to have_been_requested.once
    end

    it 'stores the token encrypted, not in the clear' do
      stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 7200 })
      fetch

      cached = Rails.cache.read(cache_key)

      expect(cached[:token]).not_to include('corp-token')
      expect(Gitlab::CryptoHelper.aes256_gcm_decrypt(cached[:token])).to eq('corp-token')
    end

    it 'expires the cache earlier than WeCom claims, since a token can lapse sooner' do
      stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 7200 })

      expect(Rails.cache).to receive(:write).with(
        anything, anything, hash_including(expires_in: 7200 - described_class::EXPIRY_MARGIN.to_i)
      )

      fetch
    end

    it 'does not cache a token that is already at the end of its life' do
      stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 60 })
      fetch

      expect(Rails.cache.read(cache_key)).to be_nil
    end

    # WeCom answers 200 and puts the failure in the body.
    it 'raises on a WeCom error code' do
      stub_gettoken({ errcode: 40001, errmsg: 'invalid credential' })

      expect { fetch }.to raise_error(described_class::Error, /40001/)
    end

    context 'when the response cannot be trusted' do
      # WeCom always reports errcode, so anything else is a failure rather than
      # something to cache and hand out.
      where(:case_name, :body) do
        [
          ['the body is empty',            {}],
          ['there is no errcode',          { access_token: 'corp-token', expires_in: 7200 }],
          ['the token is blank',           { errcode: 0, access_token: '', expires_in: 7200 }],
          ['the token is missing',         { errcode: 0, expires_in: 7200 }],
          ['expires_in is missing',        { errcode: 0, access_token: 'corp-token' }],
          ['expires_in is not positive',   { errcode: 0, access_token: 'corp-token', expires_in: 0 }]
        ]
      end

      with_them do
        it 'raises instead of returning a half-built token' do
          stub_gettoken(body)

          expect { fetch }.to raise_error(described_class::Error)
        end
      end
    end

    it 'raises on malformed JSON' do
      stub_request(:get, token_url)
        .with(query: { corpid: corp_id, corpsecret: corp_secret })
        .to_return(status: 200, body: '<html>gateway</html>')

      expect { fetch }.to raise_error(described_class::Error)
    end

    it 'raises on a non-success HTTP status' do
      stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 7200 }, status: 502)

      expect { fetch }.to raise_error(described_class::Error, /HTTP 502/)
    end

    # One company can run several custom apps, and a rotated secret must not
    # keep serving the token issued to the old one.
    it 'keeps a separate cache entry per app secret' do
      stub_gettoken({ errcode: 0, access_token: 'token-a', expires_in: 7200 })
      fetch

      stub_request(:get, token_url)
        .with(query: { corpid: corp_id, corpsecret: 'rotated-secret' })
        .to_return(status: 200, body: { errcode: 0, access_token: 'token-b', expires_in: 7200 }.to_json)

      expect(fetch('rotated-secret')).to eq(['token-b', 7200])
      expect(fetch).to eq(['token-a', 7200])
    end

    it 'does not leak the secret into the cache key' do
      expect(cache_key).not_to include(corp_secret)
    end

    context 'when another process is already fetching' do
      # A cold cache must not send every concurrent request to WeCom.
      it 'waits for the holder and reuses what it cached' do
        allow_next_instance_of(Gitlab::ExclusiveLease) do |lease|
          allow(lease).to receive(:try_obtain).and_return(false)
        end
        allow(described_class).to receive(:sleep)

        request = stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 7200 })
        Rails.cache.write(
          cache_key,
          { token: Gitlab::CryptoHelper.aes256_gcm_encrypt('cached-token'), expires_in: 7200 },
          expires_in: 60
        )

        expect(fetch).to eq(['cached-token', 7200])
        expect(request).not_to have_been_requested
      end
    end
  end

  describe '.invalidate' do
    it 'forces the next fetch to go back to WeCom' do
      request = stub_gettoken({ errcode: 0, access_token: 'corp-token', expires_in: 7200 })
      fetch
      described_class.invalidate(corp_id: corp_id, corp_secret: corp_secret)
      fetch

      expect(request).to have_been_requested.twice
    end
  end
end
