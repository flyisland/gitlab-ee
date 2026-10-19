# frozen_string_literal: true

module Gitlab
  module Feishu
    module AccessToken
      TOKEN_PATH = '/open-apis/auth/v3/tenant_access_token/internal'
      EXPIRY_MARGIN = 60
      LEASE_TIMEOUT = 30
      LEASE_RETRIES = 10
      LEASE_SLEEP = 0.5

      class << self
        def fetch(app: App)
          key = cache_key(app)

          read_cache(key) || fetch_with_lease(app, key)
        end

        def invalidate(app: App)
          Rails.cache.delete(cache_key(app))
        end

        private

        def fetch_with_lease(app, key)
          lease = ::Gitlab::ExclusiveLease.new("#{key}:lease", timeout: LEASE_TIMEOUT)
          obtained = false
          LEASE_RETRIES.times do
            obtained = lease.try_obtain
            return read_cache(key) || request_and_cache(app, key) if obtained

            cached = read_cache(key)
            return cached if cached

            sleep(LEASE_SLEEP)
          end

          raise AppResponse::TransientError, 'Feishu token refresh is in progress'
        ensure
          lease.cancel if obtained
        end

        def cache_key(app)
          fingerprint = ::Gitlab::CryptoHelper.sha256(
            ::Gitlab::Json.generate([app.api_site, app.tenant_key, app.app_id, app.app_secret])
          )
          "integration:feishu:#{fingerprint}:tenant_access_token"
        end

        def read_cache(key)
          encrypted = Rails.cache.read(key)
          return if encrypted.blank?

          ::Gitlab::CryptoHelper.aes256_gcm_decrypt(encrypted)
        end

        def request_and_cache(app, key)
          response = ::Gitlab::HTTP.post(
            "#{app.api_site}#{TOKEN_PATH}",
            headers: { 'Content-Type' => 'application/json' },
            body: ::Gitlab::Json.generate(app_id: app.app_id, app_secret: app.app_secret),
            timeout: 10, follow_redirects: false
          )
          body = AppResponse.parse(response)
          token = body['tenant_access_token']
          expiry = body['expire']
          unless token.is_a?(String) && token.present? && expiry.is_a?(Integer) && expiry > 0
            raise AppResponse::PermanentError, 'Feishu returned an invalid tenant token'
          end

          if expiry > EXPIRY_MARGIN
            Rails.cache.write(key, ::Gitlab::CryptoHelper.aes256_gcm_encrypt(token),
              expires_in: expiry - EXPIRY_MARGIN)
          end

          token
        rescue AppResponse::TokenRejected
          raise AppResponse::PermanentError, 'Feishu refused the application credentials'
        rescue ::Gitlab::HTTP::BlockedUrlError
          raise AppResponse::PermanentError, 'Feishu token endpoint is blocked'
        rescue *::Gitlab::HTTP::HTTP_ERRORS
          raise AppResponse::TransientError, 'Feishu token request failed'
        end
      end
    end
  end
end
