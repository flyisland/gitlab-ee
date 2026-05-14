# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Internal::Orbit, feature_category: :knowledge_graph do
  include WorkhorseHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:personal_access_token) { create(:personal_access_token, user: user) }
  let_it_be(:public_project) { create(:project, :public) }
  let_it_be(:private_project) { create(:project, :private) }

  let(:workhorse_headers) { workhorse_internal_api_request_header }
  let(:auth_headers) { { 'HTTP_PRIVATE_TOKEN' => personal_access_token.token } }

  before do
    stub_feature_flags(knowledge_graph_infra: true)
  end

  def redaction_params(resources:)
    { resources: resources }
  end

  def post_redaction(params:, headers: workhorse_headers.merge(auth_headers))
    post api('/internal/orbit/redaction'), params: params, headers: headers
  end

  describe 'POST /internal/orbit/redaction' do
    context 'when Workhorse token is missing' do
      it 'rejects the request' do
        post_redaction(
          params: redaction_params(
            resources: [{ resource_type: 'project', resource_ids: [1], ability: 'read_project' }]
          ),
          headers: auth_headers
        )

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'when Workhorse token is invalid' do
      it 'rejects the request' do
        post_redaction(
          params: redaction_params(
            resources: [{ resource_type: 'project', resource_ids: [1], ability: 'read_project' }]
          ),
          headers: auth_headers.merge('HTTP_GITLAB_WORKHORSE_API_REQUEST' => 'invalid-token')
        )

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'when user token is missing' do
      it 'returns 401' do
        post_redaction(
          params: redaction_params(
            resources: [
              { resource_type: 'project', resource_ids: [public_project.id], ability: 'read_project' }
            ]
          ),
          headers: workhorse_headers
        )

        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end

    context 'when user is inactive' do
      it 'returns 403' do
        blocked_user = create(:user, :blocked)
        blocked_token = create(:personal_access_token, user: blocked_user)

        post_redaction(
          params: redaction_params(
            resources: [
              { resource_type: 'project', resource_ids: [public_project.id], ability: 'read_project' }
            ]
          ),
          headers: workhorse_headers.merge('HTTP_PRIVATE_TOKEN' => blocked_token.token)
        )

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'with valid resources' do
      let_it_be(:private_project_with_access) { create(:project, :private) }

      before_all do
        private_project_with_access.add_reporter(user)
      end

      it 'returns authorization map' do
        project_ids = [
          public_project.id,
          private_project.id,
          private_project_with_access.id
        ]

        post_redaction(
          params: redaction_params(
            resources: [
              { resource_type: 'project', resource_ids: project_ids, ability: 'read_project' }
            ]
          )
        )

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['authorizations']).to contain_exactly(
          a_hash_including(
            'resource_type' => 'project',
            'authorized' => {
              public_project.id.to_s => true,
              private_project.id.to_s => false,
              private_project_with_access.id.to_s => true
            }
          )
        )
      end

      it 'rejects duplicate resource types' do
        post_redaction(
          params: redaction_params(
            resources: [
              { resource_type: 'project', resource_ids: [public_project.id], ability: 'read_project' },
              { resource_type: 'project', resource_ids: [private_project_with_access.id], ability: 'read_project' }
            ]
          )
        )

        expect(response).to have_gitlab_http_status(:bad_request)
      end

      it 'handles multiple resource types' do
        issue = create(:issue, project: public_project)

        post_redaction(
          params: redaction_params(
            resources: [
              { resource_type: 'project', resource_ids: [public_project.id], ability: 'read_project' },
              { resource_type: 'issue', resource_ids: [issue.id], ability: 'read_issue' }
            ]
          )
        )

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['authorizations'].size).to eq(2)
      end
    end

    context 'when knowledge_graph_infra flag is disabled' do
      it 'returns 404' do
        stub_feature_flags(knowledge_graph_infra: false)

        post_redaction(
          params: redaction_params(
            resources: [
              { resource_type: 'project', resource_ids: [public_project.id], ability: 'read_project' }
            ]
          )
        )

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'with OAuth token (mcp_orbit scope)' do
      let_it_be(:oauth_app) { create(:oauth_application, scopes: 'mcp_orbit') }
      let_it_be(:oauth_token) do
        create(:oauth_access_token, application: oauth_app, resource_owner: user, scopes: 'mcp_orbit')
      end

      it 'authenticates with mcp_orbit scope' do
        post_redaction(
          params: redaction_params(
            resources: [
              { resource_type: 'project', resource_ids: [public_project.id], ability: 'read_project' }
            ]
          ),
          headers: workhorse_headers.merge('HTTP_AUTHORIZATION' => "Bearer #{oauth_token.plaintext_token}")
        )

        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end
end
