# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Registrations::WelcomeController do
  describe 'email unconfirmed warning' do
    let(:user) { create(:user, :unconfirmed) }

    context 'when logged in' do
      before do
        stub_application_setting_enum('email_confirmation_setting', 'soft')

        sign_in(user)
      end

      it 'shows email unconfirmed warning' do
        get users_sign_up_welcome_path

        expect(flash[:warning]).to include('Please check your email')
      end

      context 'when it is JH COM' do
        before do
          allow(Gitlab).to receive_messages(com?: true, jh?: true)
        end

        it 'does not show email unconfirmed warning' do
          get users_sign_up_welcome_path

          expect(flash[:warning]).to be_nil
        end
      end
    end
  end
end
