# frozen_string_literal: true

module Gitlab
  module Dingtalk
    module App
      PROVIDER = 'dingtalk'

      class << self
        def configured?
          [corp_id, app_id, app_secret, agent_id].all?(&:present?) &&
            client_type.to_s == 'enterprise_internal' && agent_id.to_s.match?(/\A[1-9]\d*\z/)
        end

        def notifications_available?
          return false if ::Gitlab.com?
          return false unless ::License.feature_available?(:dingtalk_app_integration)
          return false unless ::Feature.enabled?(:jh_dingtalk_app_notification, :instance)

          configured?
        end

        def app_id
          config&.[]('app_id')
        end

        def app_secret
          config&.[]('app_secret')
        end

        def corp_id
          config&.dig('args', 'corp_id')
        end

        def agent_id
          config&.dig('args', 'agent_id')
        end

        def client_type
          config&.dig('args', 'client_type') || 'enterprise_internal'
        end

        def access_token
          ::Gitlab::Dingtalk::AccessToken.fetch(app_id: app_id, app_secret: app_secret)
        end

        def invalidate_access_token
          ::Gitlab::Dingtalk::AccessToken.invalidate(app_id: app_id, app_secret: app_secret)
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
