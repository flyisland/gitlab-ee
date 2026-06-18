# frozen_string_literal: true

module Types
  module Cd
    class EnvironmentType < ::Types::BaseObject
      graphql_name 'CdEnvironment'
      description 'Continuous deployment environment.'

      connection_type_class Types::CountableConnectionType

      authorize :read_cd_environment
      authorize_granular_token permissions: :read_cd_environment,
        boundaries: [
          { boundary: :group, boundary_type: :group },
          { boundary: :instance, boundary_type: :instance }
        ]

      field :id, Types::GlobalIDType[::Cd::Environment],
        null: false,
        description: 'Global ID of the environment.'

      field :name, GraphQL::Types::String,
        null: false,
        description: 'Name of the environment.'

      field :description, GraphQL::Types::String,
        null: true,
        description: 'Description of the environment.'

      field :group, ::Types::GroupType,
        null: true,
        description: 'Group the environment belongs to.'

      field :organization, ::Types::Organizations::OrganizationType,
        null: true,
        description: 'Organization the environment belongs to.'

      field :created_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the environment was created.'

      field :updated_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the environment was last updated.'

      def group
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Group, object.group_id).find
      end

      def organization
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Organizations::Organization, object.organization_id).find
      end
    end
  end
end
