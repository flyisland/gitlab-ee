# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Signup on EE', :with_current_organization, :js, feature_category: :user_profile do
  let(:new_user) { build_stubbed(:user) }

  before do
    stub_application_setting(require_admin_approval_after_user_signup: false)
    allow(::AntiAbuse::IdentityVerification::Settings).to receive(:arkose_enabled?).and_return(false)
  end

  describe 'password complexity', :js do
    let(:path_to_visit) { new_user_registration_path }
    let(:password_input_selector) { :new_user_password }

    it_behaves_like 'password complexity validations' do
      let(:submit_button_selector) { _('Continue') }
      let(:basic_rules) { [:length, :common, :user_info] }
    end

    context 'when all password complexity rules are enabled' do
      include_context 'with all password complexity rules enabled'

      context 'when all rules are matched' do
        let(:password) { '12345aA.' }

        it 'creates the user' do
          visit path_to_visit

          expect do
            fill_in_sign_up_form(new_user) do
              fill_in password_input_selector, with: password

              expect_password_to_be_validated
            end

            wait_for_user_to_be_created(new_user.email)
          end.to change { User.human.count }.by(1)
        end
      end
    end
  end
end
