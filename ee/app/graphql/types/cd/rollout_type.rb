# frozen_string_literal: true

module Types
  module Cd
    class RolloutType < ::Types::BaseObject
      graphql_name 'CdRollout'
      description 'Continuous deployment rollout.'

      connection_type_class Types::CountableConnectionType

      authorize :read_cd_rollout
      authorize_granular_token permissions: :read_cd_rollout,
        boundaries: [
          { boundary: :instance, boundary_type: :instance }
        ]

      field :id, Types::GlobalIDType[::Cd::Rollout],
        null: false,
        description: 'Global ID of the rollout.'

      field :state, ::Types::Cd::RolloutStateEnum,
        null: false,
        description: 'State of the rollout.'

      field :workflow_ref, GraphQL::Types::String,
        null: true,
        description: 'Workflow reference of the rollout.'

      field :started_at, Types::TimeType,
        null: true,
        description: 'Timestamp of when the rollout started.'

      field :finished_at, Types::TimeType,
        null: true,
        description: 'Timestamp of when the rollout finished.'

      field :application, ::Types::Cd::ApplicationType,
        null: true,
        description: 'Application the rollout belongs to.'

      field :version_set, ::Types::Cd::VersionSetType,
        null: true,
        description: 'Version set the rollout deploys.'

      field :application_flow_definition, ::Types::Cd::ApplicationFlowDefinitionType,
        null: true,
        description: 'Flow definition the rollout was created from.',
        experiment: { milestone: '19.2' }

      field :rollout_environments, ::Types::Cd::RolloutEnvironmentType.connection_type,
        null: true,
        description: 'Rollout environments of the rollout.',
        resolver: ::Resolvers::Cd::RolloutEnvironmentsResolver,
        experiment: { milestone: '19.2' }

      # rubocop:disable GraphQL/ExtractType -- distinct rollout associations, not a logical sub-grouping
      field :rollout_transitions, ::Types::Cd::RolloutTransitionType.connection_type,
        null: true,
        description: 'Transition journal of the rollout.',
        resolver: ::Resolvers::Cd::RolloutTransitionsResolver,
        experiment: { milestone: '19.2' }
      # rubocop:enable GraphQL/ExtractType

      field :created_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the rollout was created.'

      field :updated_at, Types::TimeType,
        null: false,
        description: 'Timestamp of when the rollout was last updated.'

      def application
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Cd::Application, object.application_id).find
      end

      def version_set
        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Cd::VersionSet, object.version_set_id).find
      end

      def application_flow_definition
        return unless object.application_flow_definition_id

        ::Gitlab::Graphql::Loaders::BatchModelLoader.new(
          ::Cd::ApplicationFlowDefinition, object.application_flow_definition_id).find
      end
    end
  end
end
