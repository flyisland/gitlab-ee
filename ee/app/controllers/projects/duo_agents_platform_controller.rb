# frozen_string_literal: true

module Projects
  class DuoAgentsPlatformController < Projects::ApplicationController
    extend Gitlab::Utils::Override
    include DuoWorkflowConcern

    DUO_AGENT_PLATFORM_ROUTES = %w[triggers agent-sessions onboarding].freeze

    AGENTS_MD_PATHS = %w[AGENTS.md .ai/AGENTS.md].freeze
    GITLAB_CI_YML_PATH = '.gitlab-ci.yml'
    AGENT_CONFIG_PATH = '.gitlab/duo/agent-config.yml'

    ONBOARDING_LEASE_TTL = 2.minutes
    ONBOARDING_CACHE_TTL = 24.hours

    feature_category :workflow_catalog
    before_action :check_access
    before_action do
      push_frontend_feature_flag(:ai_catalog_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_third_party_flows, current_user)
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
    before_action :set_has_agents_md, only: [:show]
    before_action :set_has_gitlab_ci_yml, only: [:show]
    before_action :set_has_agent_config, only: [:show]
    before_action :set_has_mr_review_instructions, only: [:show]

    def show; end

    def create_onboarding_workflow
      return render_404 unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)
      return render_403 unless can?(current_user, :duo_workflow, project)

      if already_initialized?
        return render json: { message: 'Project context has already been initialized.' },
          status: :conflict
      end

      run_onboarding_task(
        task: :project_context_init,
        in_progress_message: s_('Onboarding|Project context initialization is already in progress.')
      ) { create_and_start_onboarding_workflow }
    end

    def improve_ci
      return render_404 unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)
      return render_403 unless can?(current_user, :duo_workflow, project)

      unless gitlab_ci_yml_exists?
        return render json: { message: s_('Onboarding|No .gitlab-ci.yml found on the default branch.') },
          status: :unprocessable_entity
      end

      run_onboarding_task(
        task: :improve_ci,
        in_progress_message: s_('Onboarding|A CI improvement workflow is already in progress.')
      ) { create_and_start_improve_ci_workflow }
    end

    def create_execution_env_workflow
      return render_404 unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)
      return render_403 unless can?(current_user, :duo_workflow, project)

      if agent_config_exists?
        return render json: { message: s_('Onboarding|Execution environment has already been initialized.') },
          status: :conflict
      end

      run_onboarding_task(
        task: :init_execution_env,
        in_progress_message: s_('Onboarding|Execution environment initialization is already in progress.')
      ) { create_and_start_execution_env_workflow }
    end

    def create_mr_review_instructions_workflow
      return render_404 unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)
      return render_403 unless can?(current_user, :duo_workflow, project)

      if mr_review_instructions_exists?
        return render json: { message: s_('Onboarding|Code review instructions have already been initialized.') },
          status: :conflict
      end

      run_onboarding_task(
        task: :init_mr_review_instructions,
        in_progress_message: s_('Onboarding|Code review instructions initialization is already in progress.')
      ) { create_and_start_mr_review_instructions_workflow }
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

    def create_and_start_improve_ci_workflow
      ::Ai::Catalog::Onboarding::ExecuteDeveloperGoalService.new(
        project: project,
        current_user: current_user,
        params: { event_type: :improve_ci }
      ).execute
    end

    def create_and_start_execution_env_workflow
      ::Ai::Catalog::Onboarding::ExecuteDeveloperGoalService.new(
        project: project,
        current_user: current_user,
        params: { event_type: :init_execution_env }
      ).execute
    end

    def create_and_start_mr_review_instructions_workflow
      ::Ai::Catalog::Onboarding::ExecuteDeveloperGoalService.new(
        project: project,
        current_user: current_user,
        params: { event_type: :init_mr_review_instructions }
      ).execute
    end

    def run_onboarding_task(task:, in_progress_message:)
      in_progress_id = active_workflow_id_for(task)
      if in_progress_id
        return render json: { message: in_progress_message, workflow_id: in_progress_id },
          status: :conflict
      end

      lease_key = onboarding_lease_key(task)
      lease_uuid = Gitlab::ExclusiveLease.new(lease_key, timeout: ONBOARDING_LEASE_TTL.to_i).try_obtain

      return render json: { message: in_progress_message }, status: :conflict unless lease_uuid

      begin
        result = yield
      ensure
        Gitlab::ExclusiveLease.cancel(lease_key, lease_uuid)
      end

      if result.success?
        workflow = result.payload[:workflow]
        Rails.cache.write(onboarding_cache_key(task), workflow.id, expires_in: ONBOARDING_CACHE_TTL)
        render json: { workflow_id: workflow.id }, status: :created
      else
        render json: { message: Array(result.message).first }, status: :unprocessable_entity
      end
    end

    def active_workflow_id_for(task)
      workflow = tracked_workflow_for(task)
      return unless workflow
      return unless workflow.created? || workflow.running?

      workflow.id
    end

    def already_initialized?
      return true if agents_md_exists?

      tracked_workflow_for(:project_context_init)&.finished?
    end

    def tracked_workflow_for(task)
      strong_memoize_with(:tracked_workflow_for, task) do
        cache_key = onboarding_cache_key(task)
        cached_id = Rails.cache.read(cache_key)
        next unless cached_id

        workflow = ::Ai::DuoWorkflows::Workflow
          .for_project(project)
          .find_by(id: cached_id) # rubocop:disable CodeReuse/ActiveRecord -- cache validation requires direct query outside a finder/service

        unless workflow
          Rails.cache.delete(cache_key)
          next
        end

        workflow
      end
    end

    def onboarding_cache_key(task)
      ['duo_agent_onboarding', task.to_s, project.id]
    end

    def onboarding_lease_key(task)
      "duo_agent_onboarding:#{task}:#{project.id}"
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

      tracked = tracked_workflow_for(:project_context_init)
      in_progress_id = active_workflow_id_for(:project_context_init)
      finished_workflow_id = tracked.id if tracked&.finished? && !agents_md_exists?
      in_progress_message = s_('Onboarding|Project context initialization is already in progress.') if in_progress_id

      gon.push(
        project_context_initialized: already_initialized?,
        initialize_context_path: project_automate_onboarding_initialize_path(project),
        in_progress_onboarding_workflow_id: in_progress_id,
        finished_onboarding_workflow_id: finished_workflow_id,
        in_progress_onboarding_message: in_progress_message
      )
    end

    def set_has_gitlab_ci_yml
      return unless duo_agents_platform_params[:vueroute] == 'onboarding'
      return unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)

      gon.push(
        has_gitlab_ci_yml: gitlab_ci_yml_exists?,
        improve_ci_path: project_automate_onboarding_improve_ci_path(project)
      )
    end

    def set_has_agent_config
      return unless duo_agents_platform_params[:vueroute] == 'onboarding'
      return unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)

      gon.push(
        has_agent_config: agent_config_exists?,
        initialize_execution_env_path: project_automate_onboarding_initialize_execution_env_path(project)
      )
    end

    def set_has_mr_review_instructions
      return unless duo_agents_platform_params[:vueroute] == 'onboarding'
      return unless Feature.enabled?(:duo_agent_onboarding, current_user, type: :beta)

      gon.push(
        has_mr_review_instructions: mr_review_instructions_exists?,
        initialize_mr_review_instructions_path:
          project_automate_onboarding_initialize_mr_review_instructions_path(project)
      )
    end

    def agents_md_exists?
      default_branch = project.default_branch_or_main
      return false unless project.repository.exists?

      AGENTS_MD_PATHS.any? do |path|
        project.repository.blob_at(default_branch, path).present?
      end
    end

    def agent_config_exists?
      default_branch = project.default_branch_or_main
      return false unless project.repository.exists?

      project.repository.blob_at(default_branch, AGENT_CONFIG_PATH).present?
    end

    def gitlab_ci_yml_exists?
      default_branch = project.default_branch_or_main
      return false unless project.repository.exists?

      project.repository.blob_at(default_branch, GITLAB_CI_YML_PATH).present?
    end

    def mr_review_instructions_exists?
      return false unless project.repository.exists?

      project.repository.code_review_custom_instructions_for(project.default_branch_or_main).present?
    end

    def duo_agents_platform_params
      params.permit(:vueroute)
    end
  end
end
