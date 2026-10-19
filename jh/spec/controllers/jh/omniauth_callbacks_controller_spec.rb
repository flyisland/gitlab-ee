# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OmniauthCallbacksController, feature_category: :system_access do
  include LoginHelpers
  include RoutesHelpers

  describe '#failure' do
    let(:strategy) { OmniAuth::Strategies::Wecom.new(nil) }
    let(:exception) do
      OmniAuth::Strategies::OAuth2::CallbackError.new(:invalid_credentials, 'WeCom API error 60020')
    end

    before do
      fake_routes do
        post '/users/auth/failure' => 'omniauth_callbacks#failure'
      end

      set_devise_mapping(context: request)
      stub_omniauth_failure(strategy, :invalid_credentials, exception)
    end

    context 'when signed in' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'redirects to the authentication settings with the provider error' do
        post :failure

        expect(response).to redirect_to(profile_two_factor_auth_path)
        expect(flash[:alert]).to include('60020')
      end
    end

    context 'when signed out' do
      it 'redirects to the sign-in page' do
        post :failure

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when an admin is re-authenticating for admin mode' do
      let(:user) { create(:admin) }

      before do
        stub_application_setting(admin_mode: true)
        sign_in(user)
        session[::Gitlab::Auth::CurrentUserMode::SESSION_STORE_KEY] = {
          ::Gitlab::Auth::CurrentUserMode::ADMIN_MODE_REQUESTED_TIME_KEY => Time.current
        }
      end

      it 'redirects to the admin mode page' do
        post :failure

        expect(response).to redirect_to(new_admin_session_path)
      end
    end
  end
end
