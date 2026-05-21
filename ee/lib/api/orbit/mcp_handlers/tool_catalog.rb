# frozen_string_literal: true

module API
  module Orbit
    module McpHandlers
      module ToolCatalog
        LEGACY_TOOL_NAMES = %w[query_graph get_graph_schema].freeze
        COMMAND_TOOL_NAMES = %w[list_commands invoke_command].freeze
        TRUSTED_TOOL_NAMES = (LEGACY_TOOL_NAMES + COMMAND_TOOL_NAMES).freeze

        def self.visible_tool_names(user)
          return COMMAND_TOOL_NAMES if ::Feature.enabled?(:orbit_mcp_command_tools, user)

          LEGACY_TOOL_NAMES
        end

        def self.trusted_tool?(name)
          TRUSTED_TOOL_NAMES.include?(name)
        end
      end
    end
  end
end
