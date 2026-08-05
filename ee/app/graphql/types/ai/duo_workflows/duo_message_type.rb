# frozen_string_literal: true

module Types
  module Ai
    module DuoWorkflows
      # rubocop: disable Graphql/AuthorizeTypes -- parent authorization is enough
      class DuoMessageType < Types::BaseObject
        graphql_name 'DuoMessage'
        description 'A message in a Duo Workflow chat log'

        field :content, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: false, description: 'Content of the message.'

        field :message_type, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: false, description: 'Type of the message.'

        field :message_sub_type, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true,
          experiment: { milestone: '19.0' },
          description: 'Sub-type of the message, used to discriminate among messages of the same type.'

        field :status, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true, description: 'Status of the message.'

        field :tool_info, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true, description: 'Tool information for the message.'

        field :timestamp, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true, description: 'Timestamp of the message.'

        field :correlation_id, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true,
          description:
            'Optional client-supplied identifier echoed back to correlate ' \
            'this message with the request that initiated it.'

        field :message_id, GraphQL::Types::ID, # rubocop:disable GraphQL/ExtractType -- keeping message fields flat for backwards compatibility
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true, description: 'Opaque identifier for the message, assigned by the workflow executor.'

        field :additional_context, [Types::Ai::AdditionalContextType],
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true, description: 'Additional context items attached to the message.'

        field :role, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true, description: 'Role of the message.'

        field :component_name, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true,
          experiment: { milestone: '19.0' },
          description: 'Component name associated with the message.'

        field :subsession_id, GraphQL::Types::String,
          scopes: [:api, :read_api, :ai_features, :ai_workflows],
          null: true,
          experiment: { milestone: '19.0' },
          description: 'Subsession ID associated with the message.'

        def tool_info
          object.tool_info.to_json
        end
      end
      # rubocop: enable Graphql/AuthorizeTypes
    end
  end
end
