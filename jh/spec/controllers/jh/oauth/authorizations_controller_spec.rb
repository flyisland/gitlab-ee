# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Oauth::AuthorizationsController, :with_current_organization, feature_category: :system_access do
  let(:user) { create(:user, organizations: [current_organization]) }
  let(:application_scopes) { 'api' }
  let(:confidential) { true }

  let(:gitlab_internal_application) do
    create(
      :oauth_application,
      scopes: application_scopes,
      redirect_uri: 'http://gitlab.cn',
      confidential: confidential
    )
  end

  let(:non_gitlab_internal_application) do
    create(
      :oauth_application,
      scopes: application_scopes,
      redirect_uri: 'http://example.com',
      confidential: confidential
    )
  end

  let(:params) do
    {
      response_type: "code",
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      state: 'state'
    }
  end

  before do
    sign_in(user)
  end

  describe 'GET #new', :saas do
    subject { get :new, params: params }

    context 'when the user is blocked' do
      before do
        user.block
      end

      context "when the application is a GitLab internal application" do
        let(:application) { gitlab_internal_application }

        it 'returns 200 code and renders view' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template('doorkeeper/authorizations/new')
        end
      end

      context "when the application is not a GitLab internal application" do
        let(:application) { non_gitlab_internal_application }

        it 'returns 200 code and renders view too' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template('doorkeeper/authorizations/new')
        end
      end
    end

    context 'when the user is not blocked' do
      context "when the application is a GitLab internal application" do
        let(:application) { gitlab_internal_application }

        it 'returns 200 code and renders view' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template('doorkeeper/authorizations/new')
        end
      end

      context "when the application is not a GitLab internal application" do
        let(:application) { non_gitlab_internal_application }

        it 'returns 200 code and renders view' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template('doorkeeper/authorizations/new')
        end
      end
    end
  end
end
