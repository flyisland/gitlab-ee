# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'doorkeeper access', feature_category: :system_access do
  let_it_be(:organization) { create(:organization) }
  let!(:user) { create(:user, :with_namespace) }
  let!(:application) { create(:doorkeeper_application, organization: organization) }
  let!(:token) do
    create(
      :oauth_access_token,
      application: application,
      resource_owner: user,
      organization: organization,
      scopes: 'api'
    )
  end

  context "when user is blocked" do
    before do
      user.block
    end

    it 'returns 200 response for user endpoint' do
      get api_v4_user_path, params: { access_token: token.plaintext_token }

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'returns 200 response for namespaces endpoint' do
      get api_v4_namespaces_path, params: { access_token: token.plaintext_token }

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'returns 403 response for any other endpoint' do
      get api_v4_user_preferences_path, params: { access_token: token.plaintext_token }
      expect(response).to have_gitlab_http_status(:forbidden)

      get api_v4_personal_access_tokens_path, params: { access_token: token.plaintext_token }
      expect(response).to have_gitlab_http_status(:forbidden)
    end
  end
end
