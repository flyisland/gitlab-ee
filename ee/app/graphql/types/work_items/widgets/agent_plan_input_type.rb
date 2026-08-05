# frozen_string_literal: true

module Types
  module WorkItems
    module Widgets
      class AgentPlanInputType < BaseInputObject
        graphql_name 'WorkItemWidgetAgentPlanInput'

        argument :content, GraphQL::Types::String,
          required: true,
          description: 'Content of the agent plan.'
      end
    end
  end
end
