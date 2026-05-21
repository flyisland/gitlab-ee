# frozen_string_literal: true

module Types
  module WorkItems
    module Widgets
      # rubocop:disable Graphql/AuthorizeTypes -- authorized via parent work item
      class AgentPlanType < BaseObject
        graphql_name 'WorkItemWidgetAgentPlan'
        description 'Represents an agent plan widget.'

        implements ::Types::WorkItems::WidgetInterface

        def self.authorization_scopes
          super + [:ai_workflows]
        end

        # The work item's agent plan content may be stored in object storage, so each call
        # to `content` or `content_html` can cost a network round-trip. We cap call count so
        # that, for example, listing many work items with their agent plans is impossible.
        field :content, GraphQL::Types::String,
          null: true,
          scopes: [:api, :read_api, :ai_workflows],
          description: 'Content of the agent plan. ' \
            'This field can only be resolved for one work item in any single request.' do
          extension ::Gitlab::Graphql::Limit::FieldCallCount, limit: 1
        end

        markdown_field :content_html,
          null: true,
          scopes: [:api, :read_api, :ai_workflows],
          extensions: [::Gitlab::Graphql::Limit::FieldCallCount => { limit: 1 }],
          description: 'GitLab Flavored Markdown rendering of `content`. ' \
            'This field can only be resolved for one work item in any single request.' do |widget|
          widget.work_item.agent_plan
        end
      end
      # rubocop:enable Graphql/AuthorizeTypes
    end
  end
end
