# frozen_string_literal: true

module Gitlab
  module Dingtalk
    module AccessToken
      ENDPOINT = 'https://api.dingtalk.com/v1.0/oauth2/accessToken'
      EXPIRY_MARGIN = 10.minutes
      LEASE_TIMEOUT = 30.seconds

      class << self
        def fetch(app_id:, app_secret:)
          key = cache_key(app_id, app_secret)
          cached = read_cache(key)
          return cached if cached

          lease = ::Gitlab::ExclusiveLease.new("#{key}:lease", timeout: LEASE_TIMEOUT.to_i)
          obtained = lease.try_obtain
          raise AppResponse::TransientError, 'DingTalk token refresh is in progress' unless obtained

          read_cache(key) || request_and_cache(key, app_id, app_secret)
        ensure
          lease.cancel if obtained
        end

        def invalidate(app_id:, app_secret:)
          Rails.cache.delete(cache_key(app_id, app_secret))
        end

        private

        def cache_key(app_id, app_secret)
          fingerprint = ::Gitlab::CryptoHelper.sha256([app_id, app_secret].join(':'))
          "integration:dingtalk:notifications:#{fingerprint}:access_token"
        end

        def read_cache(key)
          encrypted = Rails.cache.read(key)
          ::Gitlab::CryptoHelper.aes256_gcm_decrypt(encrypted) if encrypted.present?
        end

        def request_and_cache(key, app_id, app_secret)
          response = ::Gitlab::HTTP.post(
            ENDPOINT,
            headers: { 'Content-Type' => 'application/json' },
            body: ::Gitlab::Json.generate(appKey: app_id, appSecret: app_secret)
          )
          body = AppResponse.parse(response, token: true)
          token = body['accessToken']
          lifetime = body['expireIn']
          unless token.is_a?(String) && token.present? && lifetime.is_a?(Integer) && lifetime > 0
            raise AppResponse::PermanentError, 'DingTalk returned an invalid token response'
          end

          ttl = [lifetime - EXPIRY_MARGIN.to_i, lifetime / 2].max
          Rails.cache.write(key, ::Gitlab::CryptoHelper.aes256_gcm_encrypt(token), expires_in: ttl)
          token
        rescue ::Gitlab::HTTP::BlockedUrlError
          raise AppResponse::PermanentError, 'DingTalk endpoint is blocked', cause: nil
        rescue *::Gitlab::HTTP::HTTP_ERRORS
          raise AppResponse::TransientError, 'DingTalk token request failed', cause: nil
        end
      end
    end
  end
end
