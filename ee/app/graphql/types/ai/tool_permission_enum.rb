# frozen_string_literal: true

module Types
  module Ai
    class ToolPermissionEnum < BaseEnum
      graphql_name 'AiToolPermission'
      description 'Permission mode for an AI tool'

      value 'ALLOW', value: 'allow', description: 'Tool is always allowed to run without approval.'
      value 'ASK', value: 'ask', description: 'Tool requires human approval before running.'
      value 'DENY', value: 'deny', description: 'Tool is always blocked from running.'
    end
  end
end
