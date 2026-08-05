# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::SecretsManagement::AccessTokens, :gitlab_secrets_manager, feature_category: :secrets_management do
  let_it_be(:owner) { create(:user) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:non_member) { create(:user) }

  describe 'POST /projects/:id/secrets_manager/access_token' do
    let_it_be(:group, freeze: false) { create(:group) }
    let_it_be(:project) { create(:project, group: group, owners: owner, developers: developer, guests: guest) }
    let_it_be_with_refind(:project_secrets_manager) { create(:project_secrets_manager, project: project) }

    let(:path) { "/projects/#{project.id}/secrets_manager/access_token" }

    before do
      provision_project_secrets_manager(project_secrets_manager, owner)
    end

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(secrets_manager_api_access: false)
      end

      it 'returns 404' do
        post api(path, developer)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when the feature flag is enabled' do
      it 'mints an access token for an authorized member' do
        post api(path, developer)

        expect(response).to have_gitlab_http_status(:created)
        expect(json_response['expires_at']).to be_present

        vault = json_response.dig('provider', 'vault')
        expect(vault['server']).to be_present
        expect(vault['namespace']).to eq(project_secrets_manager.full_project_namespace_path)
        expect(vault['path']).to eq(project_secrets_manager.ci_secrets_mount_path)
        expect(vault['version']).to eq('v2')
        expect(vault.dig('auth', 'jwt', 'path')).to eq(project_secrets_manager.api_auth_mount)
        expect(vault.dig('auth', 'jwt', 'role')).to eq(project_secrets_manager.api_auth_role)
        expect(vault.dig('auth', 'jwt', 'token')).to be_present
      end

      it 'denies a guest' do
        post api(path, guest)

        expect(response).to have_gitlab_http_status(:forbidden)
      end

      it 'denies a non-member' do
        post api(path, non_member)

        expect(response).to have_gitlab_http_status(:not_found)
      end

      it 'requires authentication' do
        post api(path)

        expect(response).to have_gitlab_http_status(:unauthorized)
      end

      it 'returns 404 when the secrets manager is not active' do
        project_secrets_manager.update_column(:status,
          SecretsManagement::BaseSecretsManager::STATUSES[:provisioning])

        post api(path, developer)

        expect(response).to have_gitlab_http_status(:not_found)
      end

      describe 'auth_via claim' do
        def expect_token_issued_with_auth_via(value)
          expect(::SecretsManagement::ApiAccess::IssueTokenService)
            .to receive(:new).with(anything, anything, auth_via: value).and_call_original
        end

        it 'records personal_access_token for PAT auth' do
          expect_token_issued_with_auth_via('personal_access_token')

          post api(path, developer)

          expect(response).to have_gitlab_http_status(:created)
        end

        it 'records oauth for OAuth token auth' do
          oauth_token = create(:oauth_access_token, resource_owner: developer, scopes: 'api')
          expect_token_issued_with_auth_via('oauth')

          post api(path, oauth_access_token: oauth_token)

          expect(response).to have_gitlab_http_status(:created)
        end

        it 'rejects browser session auth (no revocable credential)' do
          login_as(developer)
          expect(::SecretsManagement::ApiAccess::IssueTokenService).not_to receive(:new)

          post api(path)

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end

    it_behaves_like 'authorizing granular token permissions', :create_secrets_manager_api_jwt,
      expected_success_status: :created do
      let(:user) { developer }
      let(:boundary_object) { project }
      let(:request) { post api(path, personal_access_token: pat) }
    end
  end

  describe 'POST /groups/:id/secrets_manager/access_token' do
    let_it_be(:group, freeze: false) { create(:group) }
    let_it_be_with_refind(:group_secrets_manager) { create(:group_secrets_manager, group: group) }

    let(:path) { "/groups/#{group.id}/secrets_manager/access_token" }

    before_all do
      group.add_developer(developer)
      group.add_guest(guest)
    end

    before do
      provision_group_secrets_manager(group_secrets_manager, owner)
    end

    context 'when the feature flag is enabled' do
      it 'mints an access token for an authorized member' do
        post api(path, developer)

        expect(response).to have_gitlab_http_status(:created)

        vault = json_response.dig('provider', 'vault')
        expect(vault['namespace']).to eq(group_secrets_manager.full_group_namespace_path)
        expect(vault.dig('auth', 'jwt', 'path')).to eq(group_secrets_manager.api_auth_mount)
        expect(vault.dig('auth', 'jwt', 'token')).to be_present
      end

      it 'denies a guest' do
        post api(path, guest)

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    it_behaves_like 'authorizing granular token permissions', :create_secrets_manager_api_jwt,
      expected_success_status: :created do
      let(:user) { developer }
      let(:boundary_object) { group }
      let(:request) { post api(path, personal_access_token: pat) }
    end
  end
end
