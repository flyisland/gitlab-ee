# frozen_string_literal: true

module Gitlab
  module Wecom
    # Fetches and caches the corp-level access token of a WeCom custom app.
    #
    # WeCom issues one token per app: asking for a new one invalidates the token
    # another part of the application may still be holding. Sign-in and message
    # delivery therefore share this cache instead of each calling `gettoken`.
    #
    # The token is encrypted at rest because the cache is shared infrastructure
    # and the token carries the app's full permissions.
    module AccessToken
      ENDPOINT = 'https://qyapi.weixin.qq.com/cgi-bin/gettoken'

      # WeCom documents 7200s but can retire a token sooner, so the cache always
      # expires before the lifetime the response reports.
      EXPIRY_MARGIN = 10.minutes

      # How long a caller waits for whoever is already talking to WeCom.
      LEASE_TIMEOUT = 30.seconds
      LEASE_RETRIES = 10
      LEASE_SLEEP = 0.5.seconds

      Error = Class.new(StandardError)

      class << self
        # @param corp_id [String] the CorpID
        # @param corp_secret [String] the custom app's secret
        # @return [Array(String, Integer)] the token and its lifetime in seconds
        def fetch(corp_id:, corp_secret:, endpoint: ENDPOINT)
          key = cache_key(corp_id, corp_secret)

          cached = read_cache(key)
          return cached if cached

          in_lease(key) do
            # Whoever held the lease has probably just filled the cache.
            cached = read_cache(key)
            next cached if cached

            token, expires_in = request_token(corp_id, corp_secret, endpoint)
            write_cache(key, token, expires_in)

            [token, expires_in]
          end
        end

        # Drops the cached token so the next caller fetches a fresh one. Called
        # when WeCom rejects a token that has not reached its expiry yet.
        def invalidate(corp_id:, corp_secret:)
          Rails.cache.delete(cache_key(corp_id, corp_secret))
        end

        private

        # Scoped by app, not just by corp: one company can run several custom
        # apps, and rotating a secret must not keep serving the old token. The
        # secret is only ever present as a salted digest.
        def cache_key(corp_id, corp_secret)
          fingerprint = ::Gitlab::CryptoHelper.sha256(corp_secret.to_s)[0, 16]

          "integration:wecom:#{corp_id}:#{fingerprint}:access_token"
        end

        # Serializes the fetch so a cold cache does not send every concurrent
        # request to WeCom and trip its rate limit.
        def in_lease(key)
          lease = ::Gitlab::ExclusiveLease.new("#{key}:lease", timeout: LEASE_TIMEOUT.to_i)

          LEASE_RETRIES.times do
            return yield if lease.try_obtain

            cached = read_cache(key)
            return cached if cached

            sleep(LEASE_SLEEP)
          end

          # The lease holder is stuck or slow; fall back to fetching directly
          # rather than failing the sign-in outright.
          yield
        ensure
          lease&.cancel
        end

        def read_cache(key)
          cached = Rails.cache.read(key)
          return if cached.blank?

          [::Gitlab::CryptoHelper.aes256_gcm_decrypt(cached[:token]), cached[:expires_in]]
        end

        def write_cache(key, token, expires_in)
          ttl = expires_in.to_i - EXPIRY_MARGIN.to_i
          return if ttl <= 0

          Rails.cache.write(
            key,
            { token: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(token), expires_in: expires_in.to_i },
            expires_in: ttl
          )
        end

        def request_token(corp_id, corp_secret, endpoint)
          response = ::Gitlab::HTTP.get(endpoint, query: { corpid: corp_id, corpsecret: corp_secret })

          raise Error, "WeCom gettoken returned HTTP #{response.code}" unless response.success?

          validate!(::Gitlab::Json::SafeParser.parse(response.body))
        rescue ::JSON::ParserError
          raise Error, 'WeCom gettoken returned a malformed body'
        rescue ::Gitlab::HTTP::BlockedUrlError, *::Gitlab::HTTP::HTTP_ERRORS => e
          raise Error, "WeCom gettoken failed: #{e.class}"
        end

        # Fail closed: WeCom always reports `errcode`, so anything else -- a
        # missing code, a blank token, a non-positive lifetime -- is treated as a
        # failure rather than cached and handed out.
        def validate!(body)
          body = {} unless body.is_a?(Hash)
          errcode = body['errcode']

          raise Error, "WeCom gettoken returned no errcode" if errcode.nil?
          raise Error, "WeCom gettoken failed: errcode=#{errcode} errmsg=#{body['errmsg']}" unless errcode.to_i == 0

          token = body['access_token']
          expires_in = body['expires_in'].to_i

          raise Error, "WeCom gettoken returned a blank access_token" if token.blank?
          raise Error, "WeCom gettoken returned expires_in=#{body['expires_in'].inspect}" unless expires_in > 0

          [token, expires_in]
        end
      end
    end
  end
end
