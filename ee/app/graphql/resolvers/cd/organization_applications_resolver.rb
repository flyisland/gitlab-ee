# frozen_string_literal: true

module Resolvers
  module Cd
    class OrganizationApplicationsResolver < BaseResolver
      type ::Types::Cd::ApplicationType.connection_type, null: true

      def resolve
        return unless Feature.enabled?(:ai_native_deploy, current_user)
        return unless current_user&.can?(:read_cd_application, object)

        ::Cd::Application.in_organization(object)
      end
    end
  end
end
