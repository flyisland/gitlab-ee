# frozen_string_literal: true

module Projects
  class DuoAgentsPlatformController < Projects::ApplicationController
    extend Gitlab::Utils::Override
    include DuoWorkflowConcern

    DUO_AGENT_PLATFORM_ROUTES = %w[triggers agent-sessions onboarding].freeze

    AGENTS_MD_PATHS = %w[AGENTS.md .ai/AGENTS.md].freeze

    ONBOARDING_LEASE_TTL = 2.minutes
    ONBOARDING_CACHE_TTL = 30.minutes

    feature_category :workflow_catalog
    before_action :check_access
    before_action do
      push_frontend_feature_flag(:ai_catalog_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_third_party_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_filter_enabled_projects, current_user)
      push_frontend_feature_flag(:mcp_catalog_agent_tools, current_user)
      push_frontend_feature_flag(:duo_agentic_chat_prefer_mcp_tools, current_user)
      push_frontend_feature_flag(:ai_flow_trigger_pipeline_hooks, project.root_group)
      push_frontend_feature_flag(:merge_request_ready_flow_trigger, project)
      push_frontend_feature_flag(:duo_agent_onboarding, current_user, type: :beta)
      push_frontend_ability(ability: :admin_ai_catalog_item, resource: project, user: current_user)
      push_frontend_ability(ability: :admin_ai_catalog_item_consumer, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :create_ai_catalog_agent, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_foundational_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_third_party_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :create_ai_catalog_third_party_flow, resource: project, user: current_user)
      push_frontend_ability(ability: :read_ai_catalog_mcp_server, resource: project, user: current_user)
      push_frontend_ability(ability: :manage_ai_flow_triggers, resource: project, user: current_user)
      push_frontend_ability(ability: :report_ai_catalog_item, user: current_user)
      push_frontend_ability(ability: :force_hard_delete_ai_catalog_item, user: current_user)
    end
    before_action :set_has_agents_md, only: [:show]

    def show; end

    def create_onboarding_workflow
      return render_404 unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)
      return render_403 unless can?(current_user, :duo_workflow, project)

      if agents_md_exists?
        return render json: { message: 'Project context has already been initialized.' },
          status: :conflict
      end

      in_progress_id = active_onboarding_workflow_id
      if in_progress_id
        return render json: {
          message: 'Project context initialization is already in progress.',
          workflow_id: in_progress_id
        }, status: :conflict
      end

      lease_uuid = Gitlab::ExclusiveLease.new(onboarding_lease_key, timeout: ONBOARDING_LEASE_TTL.to_i).try_obtain

      unless lease_uuid
        return render json: { message: 'Project context initialization is already in progress.' },
          status: :conflict
      end

      begin
        result = create_and_start_onboarding_workflow
      ensure
        Gitlab::ExclusiveLease.cancel(onboarding_lease_key, lease_uuid)
      end

      if result.success?
        workflow = result.payload[:workflow]
        Rails.cache.write(onboarding_cache_key, workflow.id, expires_in: ONBOARDING_CACHE_TTL)
        render json: { workflow_id: workflow.id }, status: :created
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

    def create_and_start_onboarding_workflow
      ::Ai::Catalog::Onboarding::ExecuteDeveloperGoalService.new(
        project: project,
        current_user: current_user,
        params: { event_type: :init_project_context }
      ).execute
    end

    def active_onboarding_workflow_id
      cached_id = Rails.cache.read(onboarding_cache_key)
      return unless cached_id

      workflow = ::Ai::DuoWorkflows::Workflow
        .for_project(project)
        .in_status_group(:active)
        .find_by(id: cached_id) # rubocop:disable CodeReuse/ActiveRecord -- cache validation requires direct query outside a finder/service

      unless workflow
        Rails.cache.delete(onboarding_cache_key)
        return
      end

      cached_id
    end

    def onboarding_cache_key
      ['duo_agent_onboarding', 'project_context_init', project.id]
    end

    def onboarding_lease_key
      "duo_agent_onboarding:project_context_init:#{project.id}"
    end

    def check_access
      return render_404 unless current_user

      return render_404 unless Feature.enabled?(:ai_catalog_public_explore, :instance) ||
        Ability.allowed?(current_user, :duo_workflow, project)

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
        Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta) &&
          current_user.can?(:duo_workflow, project)
      end
    end

    def set_has_agents_md
      return unless duo_agents_platform_params[:vueroute] == 'onboarding'
      return unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)

      gon.push(
        has_agents_md: agents_md_exists?,
        initialize_context_path: project_automate_onboarding_initialize_path(project)
      )
    end

    def agents_md_exists?
      default_branch = project.default_branch_or_main
      return false unless project.repository.exists?

      AGENTS_MD_PATHS.any? do |path|
        project.repository.blob_at(default_branch, path).present?
      end
    end

    def duo_agents_platform_params
      params.permit(:vueroute)
    end
  end
end
