# frozen_string_literal: true

module Resolvers
  module Cd
    class EnvironmentsResolver < BaseResolver
      type ::Types::Cd::EnvironmentType.connection_type, null: true

      def resolve
        return unless Feature.enabled?(:ai_native_deploy, current_user)
        return unless current_user&.can?(:read_cd_environment, object)

        ::Cd::Environment.for_groups(object.self_and_descendants)
      end
    end
  end
end
