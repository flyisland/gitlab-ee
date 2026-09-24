# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialRegistrationsController, :with_current_organization, :phone_verification_code_enabled do
  include SetDefaultPreferredLanguage

  describe '#create' do
    let(:user_params) { build_stubbed(:user).slice(:first_name, :last_name, :email, :username, :password) }

    before do
      stub_feature_flags(arkose_labs_signup_challenge: false)
      set_default_preferred_language_to_zh_cn
    end

    context 'when it is JH COM', :saas do
      before do
        stub_feature_flags(registrations_with_phone: false)
      end

      it 'sets the user preferred language to zh_CN' do
        cookies[:preferred_language] = 'zh_CN'
        post trial_registrations_path, params: { user: user_params }

        user = User.find_by email: user_params[:email]

        expect(user).to be_present
        expect(user.preferred_language).to eq('zh_CN')
      end
    end
  end
end
