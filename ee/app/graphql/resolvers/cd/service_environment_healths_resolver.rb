# frozen_string_literal: true

module Resolvers
  module Cd
    class ServiceEnvironmentHealthsResolver < BaseResolver
      include LooksAhead

      type ::Types::Cd::ServiceEnvironmentHealthType.connection_type, null: true

      def resolve_with_lookahead(**)
        return unless Feature.enabled?(:ai_native_deploy, current_user)

        apply_lookahead(object.service_environment_healths)
      end

      private

      def unconditional_includes
        [:service]
      end
    end
  end
end
