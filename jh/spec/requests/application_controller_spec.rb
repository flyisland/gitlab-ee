# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationController, :with_current_organization do
  shared_examples 'redirections' do |path_symbol|
    let(:path) { send(path_symbol) }

    subject(:sign_in) do
      post user_session_path(user: { login: user.username, password: user.password })
    end

    context 'when SaaS', :saas, :aggregate_failures do
      it 'redirects to 401 and redirects back after login', :saas do
        get path
        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(request.session[:user_return_to]).to eq path

        sign_in
        expect(response).to redirect_to path
      end
    end

    context 'when Self-managed' do
      it 'redirects to the sign-in page' do
        get path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with redirection about 401 unauthorized' do
    let_it_be(:user) { create(:user) }
    let(:private_project) { create(:project, :private) }
    let(:private_project_path) { project_path(private_project) }
    let(:non_existing_path) { '/non-existing-path' }

    it_behaves_like 'redirections', :private_project_path
    it_behaves_like 'redirections', :non_existing_path
  end

  context 'with blocked user', :saas do
    let_it_be(:user) { create(:user, :blocked, :with_namespace) }

    context 'when user is signed in' do
      before do
        sign_in(user)
      end

      context 'when requesting some random path that is not an OAuth request or a devise request' do
        it 'redirects to login page' do
          get '/some/random/path'

          expect(response).to redirect_to(new_user_session_path)
          expect(flash[:alert]).to include('Your account has been blocked.')
        end
      end

      context 'when requesting the OAuth path' do
        it 'not redirects to login page' do
          get '/oauth/authorize'

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when requesting the devise path' do
        it 'not redirects to login page' do
          get '/users/sign_in'

          expect(response).to redirect_to(root_path)
        end
      end

      context 'when requesting the user info API' do
        it 'returns user information' do
          get api_v4_user_path

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['username']).to eq(user.username)
        end
      end
    end

    context 'when user is not signed in' do
      context 'when requesting some random path that is not an OAuth request or a devise request' do
        it 'redirect to login page' do
          get '/some/random/path'

          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end
  end
end
