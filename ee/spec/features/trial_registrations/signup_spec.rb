# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Trial Sign Up', :with_trial_types, :saas_registration, :with_current_organization, feature_category: :acquisition do
  context 'when trial_unification feature flag is enabled' do
    before do
      stub_saas_features(onboarding: true)
    end

    it 'serves the new trial registration page with the unified two-panel layout' do
      visit new_trial_registration_path

      expect(page).to have_css('.registration-marketing-panel-illustration')
    end
  end

  context 'when trial_unification feature flag is disabled' do
    before do
      stub_feature_flags(trial_unification: false, arkose_labs_signup_challenge_loading_state: false)
    end

    include IdentityVerificationHelpers

    let_it_be(:new_user) { build_stubbed(:user) }

    describe 'on GitLab.com' do
      context 'with invalid email', :js do
        before do
          # this will be removed during - https://gitlab.com/gitlab-org/gitlab/-/work_items/594274
          stub_feature_flags(subscription_sm_unification: false)
        end

        it_behaves_like 'user email validation' do
          let(:path) { new_user_registration_path }
        end
      end

      context 'with the unavailable username' do
        let(:existing_user) { create(:user) }

        it 'shows the error about existing username' do
          visit new_trial_registration_path
          click_on 'Continue'

          fill_in 'new_user_username', with: existing_user[:username]

          expect(page).to have_content('Username is already taken.')
        end
      end

      context 'when email is passed in the path', :js do
        it 'prefills the email form field' do
          visit new_trial_registration_path(email: 'foobar@email.com')

          expect(page).to have_field('Company email', with: 'foobar@email.com')
        end
      end

      it_behaves_like 'creates a user with ArkoseLabs risk band' do
        let(:signup_path) { new_trial_registration_path }
        let(:user_email) { new_user.email }
        let(:fill_and_submit_signup_form) do
          fill_in_sign_up_form(new_user)
        end
      end

      context 'when reCAPTCHA is enabled', :js do
        before do
          stub_application_setting(recaptcha_enabled: true)
        end

        it 'creates the user', quarantine: 'https://gitlab.com/gitlab-org/quality/test-failure-issues/-/issues/7605' do
          visit new_trial_registration_path

          expect { fill_in_sign_up_form(new_user) }.to change { User.count }
        end

        context 'when reCAPTCHA verification fails' do
          before do
            allow_next_instance_of(TrialRegistrationsController) do |instance|
              allow(instance).to receive(:verify_recaptcha).and_return(false)
            end
          end

          it 'does not create the user' do
            visit new_trial_registration_path

            expect { fill_in_sign_up_form(new_user) }.not_to change { User.count }
            expect(page).to have_content(_('There was an error with the reCAPTCHA. Please solve the reCAPTCHA again.'))
          end
        end
      end
    end
  end
end
