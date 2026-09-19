# frozen_string_literal: true

module Types
  module Ai
    module DuoWorkflows
      class WorkflowSourceTypeEnum < BaseEnum
        graphql_name 'DuoWorkflowSourceType'
        description 'External system that initiated a Duo Workflow session.'

        # Descriptions are spelled out rather than derived from Workflow.source_types
        # because no single transformation renders both `Slack` and `MCP` correctly.
        value 'SLACK', value: 'slack', description: 'Session initiated from Slack.'
        value 'MCP', value: 'mcp', description: 'Session initiated from MCP.'
      end
    end
  end
end
