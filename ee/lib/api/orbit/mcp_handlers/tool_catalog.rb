# frozen_string_literal: true

module API
  module Orbit
    module McpHandlers
      module ToolCatalog
        LEGACY_TOOL_NAMES = %w[query_graph get_graph_schema].freeze
        COMMAND_TOOL_NAMES = %w[list_commands invoke_command].freeze
        TRUSTED_TOOL_NAMES = (LEGACY_TOOL_NAMES + COMMAND_TOOL_NAMES).freeze
        # Full set of legacy tools gated by orbit_use_legacy_tools. Unlike
        # LEGACY_TOOL_NAMES (discovery), this also includes get_graph_status,
        # which is executable but never advertised by tools/list.
        ALL_LEGACY_TOOL_NAMES = (LEGACY_TOOL_NAMES + %w[get_graph_status]).freeze

        def self.visible_tool_names(user)
          return COMMAND_TOOL_NAMES if ::Feature.enabled?(:orbit_mcp_command_tools, user)

          LEGACY_TOOL_NAMES
        end

        # Kill-switch (default enabled). When disabled, legacy Orbit tools are
        # removed from execution, the AI Catalog picker, and DWS pre-approved
        # tools, making them genuinely unreachable rather than merely hidden.
        def self.legacy_tools_enabled?(user)
          ::Feature.enabled?(:orbit_use_legacy_tools, user)
        end

        def self.trusted_tool?(name)
          TRUSTED_TOOL_NAMES.include?(name)
        end
      end
    end
  end
end
