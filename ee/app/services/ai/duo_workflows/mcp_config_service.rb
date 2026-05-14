# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class McpConfigService
      include Gitlab::Utils::StrongMemoize

      GITLAB_PREAPPROVED_TOOLS = %w[gitlab_search search semantic_code_search].freeze
      GITLAB_TOOLS_REQUIRING_APPROVAL = [].freeze
      GITLAB_ENABLED_TOOLS = (GITLAB_PREAPPROVED_TOOLS + GITLAB_TOOLS_REQUIRING_APPROVAL).freeze

      # Workflow definition for agentic chat, which should receive MCP tools.
      # Foundational agents (e.g., "software_development", "analytics_agent/v1")
      # have their own toolsets and should not receive injected MCP tools.
      # See: https://gitlab.com/gitlab-org/gitlab/-/issues/583935
      AGENTIC_CHAT_DEFINITION = 'chat'

      def self.all_mcp_tools
        @all_mcp_tools ||= ::Mcp::Tools::Manager.new.list_tools.keys
      end

      def initialize(
        current_user, gitlab_token, workflow_definition: nil,
        ai_catalog_item_version_id: nil)
        @current_user = current_user
        @gitlab_token = gitlab_token
        @workflow_definition = workflow_definition
        @ai_catalog_item_version_id = ai_catalog_item_version_id
      end

      # This method returns configuration for supported MCP servers
      #
      # Expected configuration format is:
      #
      # {
      #   server_name: {
      #     URL: <server-url>,
      #     Headers: <headers-send-on-each-request>,
      #     Tools: <list-of-supported-tools>, # omitted/nil means all tools will be listed
      #     PreApprovedTools: <list-of-preapproved-tools> # tools that don't require user approval
      #   }
      # }
      #
      # GitLab configuration is hard-coded, while the list may also contain other server configurations
      # For example,
      # {
      #   gitlab: gitlab_mcp_server,
      #   context7: {
      #     URL: "https://mcp.context7.com/mcp",
      #   }
      # }
      #
      # Or the list can be extended by user provided configurations on namespace/project/user levels
      def execute
        return unless Feature.enabled?(:mcp_client, current_user)

        gitlab_mcp_server.merge(orbit_mcp_server).merge(ai_catalog_mcp_servers.except(:orbit))
      end

      def gitlab_enabled_tools
        return [] unless Feature.enabled?(:mcp_client, current_user)
        return [] unless gitlab_mcp_enabled?

        agent_tools_or_default(GITLAB_ENABLED_TOOLS)
      end

      private

      attr_reader :gitlab_token, :current_user, :workflow_definition, :ai_catalog_item_version_id

      def agentic_chat?
        workflow_definition == AGENTIC_CHAT_DEFINITION
      end

      def agent_has_tools?
        built_in_tool_ids.present? || agent_mcp_tools_enabled?
      end

      def agent_mcp_tools_enabled?
        Feature.enabled?(:mcp_catalog_agent_tools, current_user) && agent_mcp_tools.present?
      end

      def item_version
        return unless ai_catalog_item_version_id.present?

        ::Ai::Catalog::ItemVersion.find_by_id(ai_catalog_item_version_id)
      end
      strong_memoize_attr :item_version

      def built_in_tool_ids
        @built_in_tool_ids ||= item_version ? Array(item_version.def_tools) : []
      end

      def agent_mcp_tools
        @agent_mcp_tools ||= item_version ? Array(item_version.def_mcp_tools) : []
      end

      def gitlab_mcp_enabled?
        agentic_chat? || agent_has_tools?
      end

      def gitlab_mcp_server
        return {} unless gitlab_mcp_enabled?

        config = {
          Headers: {
            Authorization: "Bearer #{gitlab_token}"
          },
          PreApprovedTools: agent_tools_or_default(GITLAB_PREAPPROVED_TOOLS),
          Trusted: true
        }

        config[:Tools] = agent_tools_or_default(GITLAB_ENABLED_TOOLS) if agent_has_tools?

        { gitlab: config }
      end

      def orbit_mcp_server
        return {} unless orbit_enabled?

        {
          orbit: {
            Headers: {
              Authorization: "Bearer #{gitlab_token}"
            },
            PreApprovedTools: ::API::Orbit::McpHandlers::CallTool::KNOWN_TOOLS,
            Trusted: true
          }
        }
      end

      def orbit_enabled?
        agentic_chat? && Feature.enabled?(:knowledge_graph, current_user)
      end

      # When `mcp_catalog_agent_tools` is enabled, both built-in and MCP tool names
      # are intersected with the MCP server's available tools so the agent only
      # receives tools the server can actually execute.
      #
      # When the flag is disabled, built-in tools are returned as-is (pre-MCP
      # behavior). Without this guard the `& available` intersection would filter
      # out any built-in tool whose name doesn't happen to match an MCP tool,
      # silently breaking agents that have no MCP tools configured.
      def mcp_tools_for_agent
        built_in_names = Ai::Catalog::BuiltInTool.where(id: built_in_tool_ids).map(&:name) # rubocop:disable CodeReuse/ActiveRecord -- BuiltInTool is a FixedItemsModel, not a real ActiveRecord model

        if agent_mcp_tools_enabled?
          available = self.class.all_mcp_tools
          ((built_in_names + Array(agent_mcp_tools)) & available).uniq
        else
          built_in_names
        end
      end
      strong_memoize_attr :mcp_tools_for_agent

      def agent_tools_or_default(default)
        agent_has_tools? ? mcp_tools_for_agent : default
      end

      def ai_catalog_mcp_servers
        return {} unless ai_catalog_item_version_id

        item_version = ::Ai::Catalog::ItemVersion.find_by_id(ai_catalog_item_version_id)
        return {} unless Ability.allowed?(current_user, :read_ai_catalog_item, item_version)

        ::Ai::Catalog::McpServers::ConfigService.new(item_version, current_user).execute
      end
    end
  end
end
