# frozen_string_literal: true

module Types
  module Cd
    class ApplicationType < ::Types::BaseObject
      graphql_name 'CdApplication'
      description 'Continuous deployment application.'

      connection_type_class Types::CountableConnectionType

      authorize :read_cd_application
      authorize_granular_token permissions: :read_cd_application,
        boundaries: [
          { boundary: :group, boundary_type: :group },
          { boundary: :instance, boundary_type: :instance }
        ]

      field :id, Types::GlobalIDType[::Cd::Application],
        null: false,
        description: 'Global ID of the application.'

      field :name, GraphQL::Types::String,
        null: false,
        description: 'Name of the application.'

      field :description, GraphQL::Types::String,
        null: true,
        description: 'Description of the application.'

      field :group, ::Types::GroupType,
        null: true,
        description: 'Group the application belongs to.'

      field :organization, ::Types::Organizations::OrganizationType,
        null: true,
        description: 'Organization the application belongs to.'

      field :created_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the application was created.'

      field :updated_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the application was last updated.'

      def group
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Group, object.group_id).find
      end

      def organization
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Organizations::Organization, object.organization_id).find
      end
    end
  end
end
