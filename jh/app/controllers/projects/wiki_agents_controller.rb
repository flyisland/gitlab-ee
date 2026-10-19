# frozen_string_literal: true

module Projects
  class WikiAgentsController < Projects::ApplicationController
    before_action :authenticate_user!
    before_action :authorize_trigger_ai_flow!
    before_action :authorize_create_wiki!
    before_action :authorize_execute_wiki_agent!

    feature_category :duo_agent_platform

    def create
      response = ::Ai::FlowTriggers::RunService.new(
        project: project,
        flow_trigger: wiki_agent_flow_trigger,
        current_user: current_user
      ).execute(input: '', event: :manual)

      if response.success?
        redirect_to response.payload.latest_workflow.web_url, status: :see_other
      else
        redirect_to project_path(project),
          alert: s_('AiPowered|An error occurred. Please try again.'),
          status: :see_other
      end
    end

    private

    def authorize_execute_wiki_agent!
      return render_404 unless wiki_agent_flow_trigger
      return if can?(current_user, :execute_ai_catalog_item, wiki_agent_flow_trigger.ai_catalog_item_consumer)

      render_404
    end

    def wiki_agent_flow_trigger
      @wiki_agent_flow_trigger ||=
        ::JH::Ai::Catalog::WikiAgentFlowTriggerFinder.new(project).execute.first
    end
  end
end
