# frozen_string_literal: true

module Gitlab
  module Feishu
    module App
      PROVIDER = 'feishu'

      class << self
        def configured?
          app_id.present? && app_secret.present? && tenant_key.present?
        end

        def notifications_available?
          return false if ::Gitlab.com?
          return false unless ::License.feature_available?(:feishu_app_integration)
          return false unless ::Feature.enabled?(:jh_feishu_app_notification, :instance)

          configured?
        end

        def app_id
          config&.[]('app_id')
        end

        def app_secret
          config&.[]('app_secret')
        end

        def tenant_key
          config&.dig('args', 'tenant_key')
        end

        def api_site
          config&.dig('args', 'client_options', 'site').presence || ::OmniAuth::Strategies::Feishu::API_SITE
        end

        def access_token
          AccessToken.fetch(app: self)
        end

        def invalidate_access_token
          AccessToken.invalidate(app: self)
        end

        private

        def config
          return unless ::Gitlab::Auth::OAuth::Provider.enabled?(PROVIDER)

          ::Gitlab::Auth::OAuth::Provider.config_for(PROVIDER)
        end
      end
    end
  end
end
