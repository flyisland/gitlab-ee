# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationController do
  let(:user) { create(:user) }

  describe '#check_password_expiration' do
    let(:controller) { described_class.new }

    before do
      allow(controller).to receive(:session).and_return({})
      stub_licensed_features(password_expiration: true)
      stub_application_setting(password_expiration_enabled: true)
      stub_application_setting(password_expires_in_days: 90)
    end

    it 'redirects if the user is over their password expiry' do
      user.user_detail.password_last_changed_at = 91.days.ago

      allow(controller).to receive(:current_user).and_return(user)
      expect(controller).to receive(:redirect_to)
      expect(controller).to receive(:new_user_settings_password_path)

      controller.send(:check_password_expiration)
    end

    it 'does not redirect if the user is under their password expiry' do
      user.user_detail.password_last_changed_at = 89.days.ago

      allow(controller).to receive(:current_user).and_return(user)
      expect(controller).not_to receive(:redirect_to)

      controller.send(:check_password_expiration)
    end

    it 'does not redirect if the user is over their password expiry but they are an ldap user' do
      user.user_detail.password_last_changed_at = 91.days.ago

      allow(user).to receive(:ldap_user?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller).not_to receive(:redirect_to)

      controller.send(:check_password_expiration)
    end

    it "does not redirect if the user is over their password expiry but password authentication is disabled" \
      "for the web interface" do
      stub_application_setting(password_authentication_enabled_for_web: false)
      stub_application_setting(password_authentication_enabled_for_git: false)
      user.user_detail.password_last_changed_at = 91.days.ago

      allow(controller).to receive(:current_user).and_return(user)
      expect(controller).not_to receive(:redirect_to)

      controller.send(:check_password_expiration)
    end
  end

  describe '#route_not_found' do
    controller(described_class) do
      skip_before_action :authenticate_user!, only: :index

      def index
        route_not_found
      end
    end

    before do
      allow(::Gitlab).to receive(:com?).and_return(true)
    end

    context 'when user is authenticated' do
      it 'renders 404 if route not found' do
        sign_in(user)

        get :index

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is not authenticated' do
      it 'renders 404 if client is a search engine crawler' do
        request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

        get :index

        expect(response).to have_gitlab_http_status(:not_found)
      end

      it 'renders 401' do
        get :index

        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end
  end
end
