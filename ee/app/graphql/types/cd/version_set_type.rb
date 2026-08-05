# frozen_string_literal: true

module Types
  module Cd
    class VersionSetType < ::Types::BaseObject
      graphql_name 'CdVersionSet'
      description 'Continuous deployment version set.'

      connection_type_class Types::CountableConnectionType

      authorize :read_cd_version_set
      authorize_granular_token permissions: :read_cd_version_set,
        boundaries: [
          { boundary: :instance, boundary_type: :instance }
        ]

      field :id, Types::GlobalIDType[::Cd::VersionSet],
        null: false,
        description: 'Global ID of the version set.'

      field :name, GraphQL::Types::String,
        null: false,
        description: 'Name of the version set.'

      field :entries_digest, GraphQL::Types::String,
        null: true,
        description: 'Digest of the version set entries.'

      field :application, ::Types::Cd::ApplicationType,
        null: true,
        description: 'Application the version set belongs to.'

      field :version_set_entries, ::Types::Cd::VersionSetEntryType.connection_type,
        null: true,
        description: 'Entries of the version set.',
        resolver: ::Resolvers::Cd::VersionSetEntriesResolver,
        experiment: { milestone: '19.2' }

      field :rollouts, ::Types::Cd::RolloutType.connection_type,
        null: true,
        description: 'Rollouts of the version set.',
        resolver: ::Resolvers::Cd::RolloutsResolver,
        experiment: { milestone: '19.2' }

      field :created_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the version set was created.'

      field :updated_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the version set was last updated.'

      def application
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Cd::Application, object.application_id).find
      end
    end
  end
end
