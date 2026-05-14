# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects::DuoAgentsPlatform', type: :request, feature_category: :workflow_catalog do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  before do
    project.add_developer(user)
    project.project_setting.update!(duo_remote_flows_enabled: true, duo_features_enabled: true)
    sign_in(user)
    allow(Ability).to receive(:allowed?).and_call_original
    allow(Ability).to receive(:allowed?).with(user, anything, anything).and_return(true)
    allow_next_instance_of(Gitlab::Llm::TanukiBot) do |instance|
      allow(instance).to receive(:credits_available?).and_return(true)
    end
    allow(::Ai::DuoWorkflow).to receive(:enabled?).and_return(true)
  end

  describe 'GET /:namespace/:project/-/automate' do
    context 'when duo workflow is enabled' do
      context 'and the user has access to duo_workflow' do
        it 'renders successfully' do
          get project_automate_agent_sessions_path(project)

          expect(response).to have_gitlab_http_status(:ok)
        end

        it 'pushes feature flags to frontend' do
          get project_automate_agent_sessions_path(project)

          expect(response.body).to include('aiCatalogFlows')
          expect(response.body).to include('aiCatalogThirdPartyFlows')
          expect(response.body).to include('mcpCatalogAgentTools')
          expect(response.body).to include('aiFlowTriggerPipelineHooks')
        end
      end

      context 'and the user does not have access to duo_workflow' do
        before do
          allow(Ability).to receive(:allowed?).with(user, :duo_workflow, project).and_return(false)
        end

        it 'does not render' do
          get project_automate_agent_sessions_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when duo_features_enabled setting is disabled' do
      before do
        project.project_setting.update!(duo_features_enabled: false)
      end

      it 'returns 404' do
        get project_automate_agent_sessions_path(project)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when duo_remote_flows_enabled setting is disabled' do
      before do
        project.project_setting.update!(duo_remote_flows_enabled: false)
      end

      it 'returns 404' do
        get project_automate_agent_sessions_path(project)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when vueroute is agents' do
      it 'returns successfully' do
        get project_automate_agents_path(project)

        expect(response).to have_gitlab_http_status(:ok)
      end

      context 'when the user is not signed in and the project is public' do
        let_it_be(:project) { create(:project, :public) }

        before do
          sign_out(user)
        end

        it 'returns a 404' do
          get project_automate_agents_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when vueroute is flow-triggers' do
      context 'when user can manage ai flow triggers' do
        let(:subscription_purchase) do
          create(:gitlab_subscription_add_on_purchase, :duo_enterprise, :self_managed)
        end

        let(:subscription_assignment) do
          create(:gitlab_subscription_user_add_on_assignment, user: user, add_on_purchase: subscription_purchase)
        end

        before do
          project.add_maintainer(user)
          subscription_assignment # Ensure assignment is created
        end

        it 'renders successfully' do
          get project_automate_flow_triggers_path(project)

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when user cannot manage ai flow triggers' do
        before do
          allow(Ability).to receive(:allowed?).with(user, :manage_ai_flow_triggers, project).and_return(false)
        end

        it 'returns 404' do
          get project_automate_flow_triggers_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when vueroute is flows' do
      context 'when user can read flows' do
        it 'returns successfully' do
          get project_automate_flows_path(project)

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when user can read foundational flows' do
        before do
          allow(Ability).to receive(:allowed?).with(user, :read_ai_catalog_flow, project).and_return(false)
          allow(Ability).to receive(:allowed?).with(user, :read_ai_foundational_flow, project).and_return(true)
        end

        it 'returns successfully' do
          get project_automate_flows_path(project)

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when user cannot read flows or foundational flows' do
        before do
          allow(Ability).to receive(:allowed?).with(user, :read_ai_catalog_flow, project).and_return(false)
          allow(Ability).to receive(:allowed?).with(user, :read_ai_foundational_flow, project).and_return(false)
        end

        it 'returns 404' do
          get project_automate_flows_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when vueroute is mcp-servers' do
      context 'when user can read mcp servers' do
        it 'returns successfully' do
          get project_automate_mcp_servers_path(project)

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when user cannot read mcp servers' do
        before do
          allow(Ability).to receive(:allowed?).with(user, :read_ai_catalog_mcp_server,
            project).and_return(false)
        end

        it 'returns 404' do
          get project_automate_mcp_servers_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when flow-triggers are requested' do
      context 'when user is not signed in' do
        before do
          sign_out(user)
        end

        it 'redirects to sign in' do
          get project_automate_flow_triggers_path(project)

          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'when user does not have access to project' do
        let(:other_user) { create(:user) }

        before do
          sign_in(other_user)
        end

        it 'returns 404' do
          get project_automate_flow_triggers_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end

  describe 'feature category assignment' do
    it 'returns workflow_catalog for the agents route' do
      controller = Projects::DuoAgentsPlatformController.new
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(vueroute: 'agents'))

      expect(controller.feature_category).to eq('workflow_catalog')
    end

    it 'returns workflow_catalog for the flows route' do
      controller = Projects::DuoAgentsPlatformController.new
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(vueroute: 'flows'))

      expect(controller.feature_category).to eq('workflow_catalog')
    end

    it 'returns duo_agent_platform for the triggers route' do
      controller = Projects::DuoAgentsPlatformController.new
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(vueroute: 'triggers'))

      expect(controller.feature_category).to eq('duo_agent_platform')
    end

    it 'returns duo_agent_platform for the agent-sessions route' do
      controller = Projects::DuoAgentsPlatformController.new
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(vueroute: 'agent-sessions'))

      expect(controller.feature_category).to eq('duo_agent_platform')
    end

    it 'returns workflow_catalog when no vueroute is set' do
      controller = Projects::DuoAgentsPlatformController.new
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new({}))

      expect(controller.feature_category).to eq('workflow_catalog')
    end
  end
end
