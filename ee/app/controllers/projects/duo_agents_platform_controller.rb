# frozen_string_literal: true

module Projects
  class DuoAgentsPlatformController < Projects::ApplicationController
    extend Gitlab::Utils::Override
    include DuoWorkflowConcern

    DUO_AGENT_PLATFORM_ROUTES = %w[triggers agent-sessions onboarding].freeze

    feature_category :workflow_catalog
    before_action :check_access
    before_action do
      push_frontend_feature_flag(:ai_catalog_third_party_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_synthetic_foundational_items, current_user)
      push_frontend_feature_flag(:mcp_catalog_agent_tools, current_user)
      push_frontend_feature_flag(:duo_agentic_chat_prefer_mcp_tools, current_user)
      push_frontend_feature_flag(:duo_agent_onboarding, current_user, type: :beta)
      push_frontend_ability(ability: :admin_ai_catalog_item, resource: project, user: current_user)
      push_frontend_ability(ability: :admin_ai_catalog_item_consumer, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :create_ai_catalog_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :create_ai_catalog_agent, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_foundational_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_third_party_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :create_ai_catalog_third_party_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_mcp_server, resource: project, user: current_user)
      push_frontend_ability(ability: :manage_ai_flow_triggers, resource: project, user: current_user)
      push_frontend_ability(ability: :report_ai_catalog_item, user: current_user)
      push_frontend_ability(ability: :force_hard_delete_ai_catalog_item, user: current_user)
    end
    before_action :set_onboarding_state, only: [:show]

    def show; end

    def setup_onboarding
      return render_404 unless onboarding_enabled?
      return render_403 unless can?(current_user, :duo_workflow, project)

      result = ::Ai::Catalog::Onboarding::RunService.new(
        project: project,
        current_user: current_user,
        params: { event_type: setup_params[:event_type] }
      ).execute

      if result.success?
        render json: result.payload, status: :created
      else
        render json: { message: Array(result.message).first }, status: :unprocessable_entity
      end
    end

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
      return render_404 unless current_user

      return render_404 unless Feature.enabled?(:ai_catalog_public_explore, :instance) ||
        Ability.allowed?(current_user, :read_duo_agent_platform, project)

      if specific_vueroute?
        render_404 unless authorized_for_route?
        return
      end

      render_404 unless duo_workflow_enabled?
    end

    def specific_vueroute?
      %w[agents flows triggers mcp-servers onboarding].include?(duo_agents_platform_params[:vueroute])
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
      when 'onboarding'
        onboarding_enabled? && current_user.can?(:duo_workflow, project)
      end
    end

    def set_onboarding_state
      return unless duo_agents_platform_params[:vueroute] == 'onboarding'
      return unless onboarding_enabled?

      gon.push(
        onboarding_setup_path: project_automate_onboarding_setup_path(project),
        onboarding_initializers: onboarding_initializers_state
      )
    end

    def onboarding_initializers_state
      tracker = ::Ai::Catalog::Onboarding::WorkflowTracker.new(project)

      ::Ai::Catalog::Onboarding::Initializer.all.map do |initializer|
        workflow = tracker.workflow_for(initializer.event_type)

        {
          event_type: initializer.event_type,
          display_name: initializer.display_name,
          description: initializer.description,
          target_file: initializer.target_file,
          applicable: initializer.applicable_for?(project),
          skipped_reason: initializer.skip_reason(project),
          status: workflow&.status_name,
          workflow_id: workflow&.id
        }
      end
    end

    def onboarding_enabled?
      Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)
    end

    def setup_params
      params.permit(:event_type)
    end

    def duo_agents_platform_params
      params.permit(:vueroute)
    end
  end
end
