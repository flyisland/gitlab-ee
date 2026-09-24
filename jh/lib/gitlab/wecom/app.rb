# frozen_string_literal: true

module Gitlab
  module Wecom
    # The WeCom custom application this instance talks to.
    #
    # Sign-in and message delivery share one application, and its credentials
    # live in the OmniAuth provider configuration. That is the only place they
    # can live: OmniAuth providers are injected at boot, and an initializer
    # cannot read the database. Keeping a second copy in application settings
    # would only let the two drift apart.
    module App
      PROVIDER = 'wecom'

      class << self
        def configured?
          corp_id.present? && corp_secret.present? && agent_id.present?
        end

        # Delivery is gated on the licence, the feature flag and the app being
        # configured. Sign-in is deliberately not gated on the flag: it ships
        # ahead of delivery.
        def notifications_available?
          return false if ::Gitlab.com?
          return false unless ::License.feature_available?(:wecom_app_integration)
          return false unless ::Feature.enabled?(:jh_wecom_app_notification, :instance)

          configured?
        end

        def corp_id
          config&.[]('app_id')
        end

        def corp_secret
          config&.[]('app_secret')
        end

        def agent_id
          config&.dig('args', 'agent_id')
        end

        # Sign-in and delivery read the same configured host, so the two can
        # never end up talking to different servers.
        def api_site
          config&.dig('args', 'client_options', 'site').presence ||
            ::OmniAuth::Strategies::Wecom::API_SITE
        end

        def access_token
          ::Gitlab::Wecom::AccessToken.fetch(
            corp_id: corp_id,
            corp_secret: corp_secret,
            endpoint: "#{api_site}#{::OmniAuth::Strategies::Wecom::TOKEN_PATH}"
          )
        end

        def invalidate_access_token
          ::Gitlab::Wecom::AccessToken.invalidate(corp_id: corp_id, corp_secret: corp_secret)
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
