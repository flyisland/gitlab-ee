# frozen_string_literal: true

module Resolvers
  module Cd
    class OrganizationEnvironmentsResolver < BaseResolver
      type ::Types::Cd::EnvironmentType.connection_type, null: true

      def resolve
        return unless Feature.enabled?(:ai_native_deploy, current_user)
        return unless current_user&.can?(:read_cd_environment, object)

        ::Cd::Environment.in_organization(object)
      end
    end
  end
end
