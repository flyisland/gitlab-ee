# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Security::AgentArtifactsController, feature_category: :compliance_management do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }

  describe 'GET #index' do
    subject(:request) { get group_security_agent_artifacts_path(group) }

    context 'when user is not authorized' do
      before_all do
        group.add_maintainer(user)
      end

      before do
        sign_in(user)
        stub_licensed_features(group_level_compliance_dashboard: true)
      end

      it 'returns 404' do
        request

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is authorized' do
      before_all do
        group.add_owner(user)
      end

      before do
        sign_in(user)
        stub_licensed_features(group_level_compliance_dashboard: true)
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

      context 'when group_level_compliance_dashboard is not available' do
        before do
          stub_licensed_features(group_level_compliance_dashboard: false)
        end

        it 'returns 404' do
          request

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end
end
