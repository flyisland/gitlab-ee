# frozen_string_literal: true

module Types
  module Ai
    class BulkToolRuleInputType < BaseInputObject
      graphql_name 'BulkToolRuleInput'
      description 'Input for a single tool rule update within a bulk operation.'

      argument :tool_id, GraphQL::Types::String,
        required: true,
        description: 'Tool name string identifying the tool to update. For example, "create_issue".'

      argument :web_access, Types::Ai::ToolPermissionEnum,
        required: false,
        description: 'Permission mode for web surface. ' \
          'Omitting the field sets it to null, clearing any existing value.'

      argument :local_access, Types::Ai::ToolPermissionEnum,
        required: false,
        description: 'Permission mode for local or IDE surface. ' \
          'Omitting the field sets it to null, clearing any existing value.'
    end
  end
end
