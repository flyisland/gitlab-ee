# frozen_string_literal: true

module JH
  module Gitlab
    module JsRoutes
      # Omniauth providers that are only registered in JH. Route names derived
      # from these providers (e.g. user_cas3_omniauth_authorize,
      # users_import_dingtalk_callback) must be excluded from generated path
      # helpers because the routes only exist in JH, not in upstream CE.
      JH_ONLY_OMNIAUTH_PROVIDERS = %w[cas3 dingtalk wecom].freeze

      module ClassMethods
        extend ::Gitlab::Utils::Override

        override :route_pairs

        def route_pairs
          super.reject { |global_route, _| jh_route?(global_route) }
        end

        private

        def jh_route?(global_route)
          jh_source_location?(global_route) || jh_omniauth_route?(global_route)
        end

        def jh_source_location?(route)
          return false unless route.respond_to?(:source_location)

          source_location = route.source_location
          return false unless source_location

          source_location.delete_prefix(Rails.root.to_s).start_with?('/jh/config/routes')
        end

        def jh_omniauth_route?(route)
          return false unless route.respond_to?(:name)

          route_name = route.name.to_s
          JH_ONLY_OMNIAUTH_PROVIDERS.any? { |provider| route_name.include?(provider) }
        end
      end

      def self.prepended(base)
        base.singleton_class.prepend ClassMethods
      end
    end
  end
end
