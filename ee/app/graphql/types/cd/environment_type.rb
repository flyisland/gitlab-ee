# frozen_string_literal: true

module Types
  module Cd
    class EnvironmentType < ::Types::BaseObject
      graphql_name 'CdEnvironment'
      description 'Continuous deployment environment.'

      connection_type_class Types::CountableConnectionType

      authorize :read_cd_environment
      authorize_granular_token permissions: :read_cd_environment,
        boundary: :instance,
        boundary_type: :instance

      field :id, Types::GlobalIDType[::Cd::Environment],
        null: false,
        description: 'Global ID of the environment.'

      field :name, GraphQL::Types::String,
        null: false,
        description: 'Name of the environment.'

      field :description, GraphQL::Types::String,
        null: true,
        description: 'Description of the environment.'

      field :tier, ::Types::Cd::EnvironmentTierEnum,
        null: false,
        description: 'Tier of the environment.'

      field :organization, ::Types::Organizations::OrganizationType,
        null: true,
        description: 'Organization the environment belongs to.'

      field :created_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the environment was created.'

      field :updated_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the environment was last updated.'

      field :environment_driver_bindings, ::Types::Cd::EnvironmentDriverBindingType.connection_type,
        null: true,
        description: 'Driver bindings of the environment.',
        resolver: ::Resolvers::Cd::EnvironmentDriverBindingsResolver,
        experiment: { milestone: '19.2' }

      field :service_environment_healths, ::Types::Cd::ServiceEnvironmentHealthType.connection_type,
        null: true,
        description: 'Observed service health in the environment.',
        resolver: ::Resolvers::Cd::ServiceEnvironmentHealthsResolver,
        experiment: { milestone: '19.2' }

      field :rollout_environments, ::Types::Cd::RolloutEnvironmentType.connection_type,
        null: true,
        description: 'Rollout environments of the environment.',
        resolver: ::Resolvers::Cd::RolloutEnvironmentsResolver,
        experiment: { milestone: '19.2' }

      def organization
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Organizations::Organization, object.organization_id).find
      end
    end
  end
end
