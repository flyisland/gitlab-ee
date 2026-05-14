# frozen_string_literal: true

module Types
  module Security
    module Ascp
      # rubocop: disable Graphql/AuthorizeTypes -- Authorization handled by parent resolver
      class ComponentType < BaseObject
        graphql_name 'AscpComponent'
        description 'A logical component of a project identified by ASCP security scanning'

        field :id, ::Types::GlobalIDType[::Security::Ascp::Component],
          null: false,
          description: 'Global ID of the component.'

        field :title, GraphQL::Types::String,
          null: false,
          description: 'Title of the component.'

        field :description, GraphQL::Types::String,
          null: true,
          description: 'Description of the component.'

        field :sub_directory, GraphQL::Types::String,
          null: false,
          description: 'Sub-directory containing the component.'

        field :expected_user_behavior, GraphQL::Types::String,
          null: true,
          description: 'Expected user behavior for the component.'

        field :scan, Types::Security::Ascp::ScanType,
          null: false,
          description: 'Scan when the component was identified.'

        field :security_context, Types::Security::Ascp::SecurityContextType,
          null: true,
          description: 'Security context for the component.'

        field :dependencies, Types::Security::Ascp::ComponentType.connection_type,
          null: false,
          description: 'Components the component depends on.',
          method: :dependency_components

        field :created_at, Types::TimeType,
          null: false,
          description: 'Timestamp when the component was created.'

        field :updated_at, Types::TimeType,
          null: false,
          description: 'Timestamp when the component was last updated.'

        def scan
          ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Security::Ascp::Scan, object.scan_id).find
        end
      end
      # rubocop: enable Graphql/AuthorizeTypes
    end
  end
end
