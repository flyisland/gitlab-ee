# frozen_string_literal: true

module Resolvers
  module Cd
    class OrganizationEnvironmentsResolver < BaseResolver
      type ::Types::Cd::EnvironmentType.connection_type, null: true

      argument :tier, ::Types::Cd::EnvironmentTierEnum,
        required: false,
        description: 'Filter environments by tier.'

      def resolve(tier: nil)
        return unless Feature.enabled?(:ai_native_deploy, current_user)
        return unless current_user&.can?(:read_cd_environment, object)

        environments = ::Cd::Environment.in_organization(object)
        environments = environments.with_tier(tier) if tier
        environments
      end
    end
  end
end
