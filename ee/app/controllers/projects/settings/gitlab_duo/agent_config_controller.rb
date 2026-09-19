# frozen_string_literal: true

module Projects
  module Settings
    module GitlabDuo
      # Generates .gitlab/duo/agent-config.yml by opening a draft merge request.
      class AgentConfigController < Projects::ApplicationController
        include DuoWorkflowConcern

        EVENT_TYPE = ::Ai::DuoWorkflow::ProjectReadiness::AGENT_CONFIG_EVENT_TYPE

        feature_category :duo_agent_platform

        before_action :authorize_generate_agent_config!

        def create
          result = ::Ai::Catalog::Onboarding::RunService.new(
            project: project,
            current_user: current_user,
            params: { event_type: EVENT_TYPE }
          ).execute

          if result.success?
            render json: result.payload, status: :created
          else
            render json: { message: Array(result.message).first, workflow_id: result.payload[:workflow_id] }.compact,
              status: :unprocessable_entity
          end
        end

        private

        def authorize_generate_agent_config!
          return render_404 unless Feature.enabled?(:duo_agent_readiness_settings, current_user, type: :wip)
          # RunService does not gate on these; the platform controllers do it via check_access.
          return render_404 unless duo_workflow_enabled?
          return render_403 unless can?(current_user, :duo_workflow, project)

          # Maintainer action; RunService alone only enforces :duo_workflow (developer).
          render_403 unless can?(current_user, :update_duo_setting, project)
        end
      end
    end
  end
end
