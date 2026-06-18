# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class McpConfigService
      include Gitlab::Utils::StrongMemoize

      GITLAB_PREAPPROVED_TOOLS = %w[
        gitlab_search search semantic_code_search
        get_merge_request get_merge_request_commits
        get_merge_request_diffs get_merge_request_pipelines
        get_pipeline_jobs get_job_log
        get_issue get_workitem_notes
        get_saved_view_work_items search_labels
        get_mcp_server_version
      ].freeze
      GITLAB_TOOLS_REQUIRING_APPROVAL = [].freeze
      GITLAB_ENABLED_TOOLS = (GITLAB_PREAPPROVED_TOOLS + GITLAB_TOOLS_REQUIRING_APPROVAL).freeze
      ToolCatalog = ::API::Orbit::McpHandlers::ToolCatalog
      ORBIT_PREAPPROVED_TOOLS = ToolCatalog::TRUSTED_TOOL_NAMES

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
        return {} unless orbit_mcp_client_enabled?

        tools = orbit_tools_to_inject

        config = {
          Headers: {
            Authorization: "Bearer #{gitlab_token}"
          },
          PreApprovedTools: tools,
          Trusted: true
        }

        config[:Tools] = tools if custom_agent?

        { orbit: config }
      end

      def orbit_mcp_client_enabled?
        # Don't inject orbit tools when running a custom agent that
        # has not selected any orbit tools. Custom agents that want
        # orbit access must explicitly select orbit tools.
        return false if custom_agent? && agent_orbit_tools.none?

        # All gating (platform availability, per-user preference flag,
        # killswitch, and granular subsettings) lives behind the
        # ::Ai::Orbit::Settings facade so this service does not have to
        # know about individual feature flags or preference shapes.
        orbit_enabled_for_flow?
      end

      def orbit_enabled_for_flow?
        if code_review?
          # Duo Code Review is flat-rate; exclude from the foundational catch-all
          # until the flow integrates Orbit deliberately and is benchmarked.
          false
        elsif custom_agent?
          ::Ai::Orbit::Settings.custom_agents_enabled?(current_user)
        elsif orbit_agent?
          ::Ai::Orbit::Settings.agent_enabled?(current_user)
        elsif agentic_chat?
          ::Ai::Orbit::Settings.chat_enabled?(current_user)
        else
          # Catch-all for non-chat foundational agents (e.g. 'software_development',
          # 'security_analyst_agent/v1'). Also covers nil and unrecognized
          # workflow definitions; add a new subsetting and explicit branch
          # above if we ever need to gate those separately.
          ::Ai::Orbit::Settings.foundational_enabled?(current_user)
        end
      end

      def code_review?
        workflow_definition&.start_with?('code_review/')
      end

      def custom_agent?
        ai_catalog_item_version_id.present? && agent_has_tools?
      end

      # Returns the orbit tools to include in the MCP config.
      # For custom agents, only the explicitly selected orbit tools;
      # for plain agentic chat / dedicated orbit agent, all orbit tools.
      def orbit_tools_to_inject
        custom_agent? ? agent_orbit_tools : orbit_preapproved_tools
      end

      def agent_orbit_tools
        Array(agent_mcp_tools) & orbit_preapproved_tools
      end
      strong_memoize_attr :agent_orbit_tools

      # Pre-approved orbit tools for this request. When orbit_use_legacy_tools is
      # disabled, legacy tools (query_graph, get_graph_schema, get_graph_status)
      # are removed so they are neither pre-approved nor injected.
      def orbit_preapproved_tools
        return ORBIT_PREAPPROVED_TOOLS if ToolCatalog.legacy_tools_enabled?(current_user)

        ORBIT_PREAPPROVED_TOOLS - ToolCatalog::ALL_LEGACY_TOOL_NAMES
      end
      strong_memoize_attr :orbit_preapproved_tools

      def orbit_agent?
        workflow_definition&.start_with?('orbit_agent')
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
