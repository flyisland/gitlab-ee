# frozen_string_literal: true

module Projects
  class DuoAgentsPlatformController < Projects::ApplicationController
    extend Gitlab::Utils::Override
    include DuoWorkflowConcern

    DUO_AGENT_PLATFORM_ROUTES = %w[triggers agent-sessions].freeze

    feature_category :workflow_catalog
    before_action :check_access
    before_action do
      push_frontend_feature_flag(:ai_catalog_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_third_party_flows, current_user)
      push_frontend_feature_flag(:mcp_catalog_agent_tools, current_user)
      push_frontend_feature_flag(:ai_flow_trigger_pipeline_hooks, project.root_group)
      push_frontend_ability(ability: :admin_ai_catalog_item, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_foundational_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_third_party_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :create_ai_catalog_third_party_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_mcp_server, resource: project, user: current_user)
      push_frontend_ability(ability: :manage_ai_flow_triggers, resource: project, user: current_user)
    end

    def show; end

    override :feature_category
    def feature_category
      if DUO_AGENT_PLATFORM_ROUTES.include?(duo_agents_platform_params[:vueroute])
        'duo_agent_platform'
      else
        super
      end
    end

    private

    def check_access
      return render_404 unless Ability.allowed?(current_user, :duo_workflow, project)

      if specific_vueroute?
        render_404 unless authorized_for_route?
        return
      end

      render_404 unless duo_workflow_enabled?
    end

    def specific_vueroute?
      %w[agents flows triggers mcp-servers].include?(duo_agents_platform_params[:vueroute])
    end

    def authorized_for_route?
      case duo_agents_platform_params[:vueroute]
      when 'agents'
        true
      when 'triggers'
        current_user.can?(:manage_ai_flow_triggers, project)
      when 'flows'
        current_user.can?(:read_ai_catalog_flow, project) ||
          current_user.can?(:read_ai_foundational_flow, project)
      when 'mcp-servers'
        current_user.can?(:read_ai_catalog_mcp_server, project)
      end
    end

    def duo_agents_platform_params
      params.permit(:vueroute)
    end
  end
end
