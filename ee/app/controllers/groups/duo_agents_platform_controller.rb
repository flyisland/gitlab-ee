# frozen_string_literal: true

module Groups
  class DuoAgentsPlatformController < Groups::ApplicationController
    feature_category :workflow_catalog

    before_action :ensure_root_group
    before_action :check_access
    before_action do
      push_frontend_feature_flag(:ai_catalog_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_third_party_flows, current_user)
      push_frontend_feature_flag(:mcp_catalog_agent_tools, current_user)
      push_frontend_ability(ability: :read_ai_catalog_flow, resource: group, user: current_user)
      push_frontend_ability(ability: :read_ai_foundational_flow, resource: group, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_mcp_server, resource: group, user: current_user)
      push_frontend_ability(ability: :manage_ai_flow_triggers, resource: group, user: current_user)
    end

    def show; end

    private

    def check_access
      return render_404 unless Ability.allowed?(current_user, :duo_workflow, group)

      return unless specific_vueroute?

      render_404 unless authorized_for_route?
    end

    def ensure_root_group
      render_404 unless group.root?
    end

    def specific_vueroute?
      %w[agents flows mcp-servers].include?(duo_agents_platform_params[:vueroute])
    end

    def authorized_for_route?
      case duo_agents_platform_params[:vueroute]
      when 'agents'
        true
      when 'flows'
        current_user.can?(:read_ai_catalog_flow, group) ||
          current_user.can?(:read_ai_foundational_flow, group)
      when 'mcp-servers'
        current_user.can?(:read_ai_catalog_mcp_server, group)
      end
    end

    def duo_agents_platform_params
      params.permit(:vueroute)
    end
  end
end
