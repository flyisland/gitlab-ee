# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::AgentArtifactsController, feature_category: :compliance_management do
  let_it_be(:user, freeze: false) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }

  describe 'GET #index' do
    subject(:request) { get project_security_agent_artifacts_path(project) }

    context 'when user is not authorized' do
      before_all do
        project.add_maintainer(user)
      end

      before do
        sign_in(user)
        stub_licensed_features(project_level_compliance_dashboard: true)
      end

      it 'returns 404' do
        request

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is authorized' do
      before_all do
        project.add_owner(user)
      end

      before do
        sign_in(user)
        stub_licensed_features(project_level_compliance_dashboard: true)
      end

      context 'when agent_artifacts_page feature flag is disabled' do
        before do
          stub_feature_flags(agent_artifacts_page: false)
        end

        it 'returns 404' do
          request

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'when agent_artifacts_page feature flag is enabled' do
        before do
          stub_feature_flags(agent_artifacts_page: true)
        end

        it 'renders the index page' do
          request

          expect(response).to have_gitlab_http_status(:ok)
          expect(response.body).to include('js-agent-artifacts')
        end
      end

      context 'when project_level_compliance_dashboard is not available' do
        before do
          stub_licensed_features(project_level_compliance_dashboard: false)
        end

        it 'returns 404' do
          request

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end
end
