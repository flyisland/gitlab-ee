# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RegistrationsController, :with_current_organization, feature_category: :user_management do
  include TermsHelper
  include FullNameHelper

  before do
    stub_application_setting(require_admin_approval_after_user_signup: false)
  end

  describe '#create' do
    before do
      allow(::Gitlab::ApplicationRateLimiter).to receive(:throttled?).and_return(false)
    end

    let_it_be(:base_user_params) do
      {
        first_name: 'first',
        last_name: 'last',
        username: FFaker::InternetSE.login_user_name,
        email: FFaker::Internet.email,
        password: User.random_password
      }
    end

    let_it_be(:user_params) { { user: base_user_params } }

    let(:session_params) { {} }

    subject { post(:create, params: user_params, session: session_params) }

    context 'when user posts register form' do
      before do
        post :create, params: { new_user: base_user_params }
      end

      it 'sets the first name and last name automatically' do
        expect(User.last.first_name).to eq('first')
        expect(User.last.last_name).to eq('last')
      end
    end
  end
end
