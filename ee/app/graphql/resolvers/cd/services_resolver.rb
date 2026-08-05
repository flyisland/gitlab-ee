# frozen_string_literal: true

module Resolvers
  module Cd
    class ServicesResolver < BaseResolver
      include LooksAhead

      type ::Types::Cd::ServiceType.connection_type, null: true

      alias_method :application, :object

      def resolve_with_lookahead(**)
        return unless Feature.enabled?(:ai_native_deploy, current_user)

        apply_lookahead(application.services)
      end

      private

      def preloads
        {
          service_environment_healths: [:service_environment_healths]
        }
      end
    end
  end
end
