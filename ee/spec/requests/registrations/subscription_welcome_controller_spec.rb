# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Registrations::SubscriptionWelcomeController, feature_category: :onboarding do
  include SessionHelpers

  let(:onboarding_enabled?) { true }

  before do
    stub_saas_features(onboarding: onboarding_enabled?)
  end

  shared_examples 'onboarding is not available' do
    context 'when user is not in onboarding' do
      before do
        user.update!(onboarding_in_progress: false)
      end

      it { is_expected.to redirect_to(root_path) }
    end

    context 'when onboarding feature is not available' do
      let(:onboarding_enabled?) { false }

      it { is_expected.to have_gitlab_http_status(:not_found) }
    end
  end

  describe 'GET show' do
    let_it_be(:user, reload: true) do
      create(
        :user, onboarding_in_progress: true, onboarding_status_email_opt_in: false,
        onboarding_status_registration_type: 'subscription'
      )
    end

    subject(:get_show) do
      get users_sign_up_welcome_path
      response
    end

    context 'with signed in user' do
      before do
        sign_in(user)
      end

      it { is_expected.to have_gitlab_http_status(:ok) }

      it_behaves_like 'onboarding is not available'

      context 'when 2FA is required from group' do
        before do
          user.update!(require_two_factor_authentication_from_group: true)
          sign_in(user)
        end

        it { is_expected.not_to redirect_to(profile_two_factor_auth_path) }
      end

      context 'when the welcome step is completed' do
        before do
          user.update!(onboarding_status_setup_for_company: true)
        end

        context 'when user is confirmed' do
          before do
            sign_in(user)
          end

          it { is_expected.to redirect_to(dashboard_projects_path) }
        end

        context 'when user is not confirmed' do
          before do
            stub_application_setting_enum('email_confirmation_setting', 'hard')

            sign_in(user)

            user.update!(confirmed_at: nil)
          end

          it { is_expected.to redirect_to user_session_path }
        end
      end
    end
  end

  describe 'PUT update' do
    let(:user) do
      create(
        :user, onboarding_in_progress: true, onboarding_status_email_opt_in: false,
        onboarding_status_registration_type: 'subscription'
      )
    end

    let(:onboarding_status_role) { 0 }
    let(:onboarding_status_setup_for_company) { 'false' }
    let(:onboarding_status_joining_project) { 'false' }
    let(:onboarding_status_registration_objective) { 2 }

    let(:update_params) do
      {
        user: {
          onboarding_status_role: onboarding_status_role,
          onboarding_status_setup_for_company: onboarding_status_setup_for_company,
          onboarding_status_joining_project: onboarding_status_joining_project,
          onboarding_status_registration_objective: onboarding_status_registration_objective
        },
        jobs_to_be_done_other: '_jobs_to_be_done_other_',
        glm_source: 'some_source',
        glm_content: 'some_content'
      }
    end

    subject(:patch_update) do
      put users_sign_up_welcome_path, params: update_params
      response
    end

    context 'with a signed in user' do
      before do
        sign_in(user)
      end

      it_behaves_like 'onboarding is not available'

      context 'when onboarding feature is available' do
        it 'tracks successful submission event' do
          patch_update

          expect_snowplow_event(
            category: 'registrations:subscription_welcome:update',
            action: 'successfully_submitted_form',
            user: user,
            label: 'subscription_registration'
          )
        end

        context 'when joining_project is "true"' do
          let(:onboarding_status_joining_project) { 'true' }

          it 'tracks join a project event' do
            patch_update

            expect_snowplow_event(
              category: 'registrations:subscription_welcome:update',
              action: 'select_button',
              user: user,
              label: 'join_a_project'
            )
          end

          it 'sets the cookie' do
            expect(patch_update.cookies['signup_with_joining_a_project']).to be_present
          end
        end

        context 'when joining_project is "false"' do
          it 'does not track join a project event' do
            patch_update

            expect_no_snowplow_event(
              category: 'registrations:subscription_welcome:update',
              action: 'select_button',
              user: user,
              label: 'join_a_project'
            )
          end

          it 'does not set the cookie' do
            expect(patch_update.cookies['signup_with_joining_a_project']).not_to be_present
          end
        end

        context 'when user return to is populated as expected for subscriptions', :clean_gitlab_redis_sessions do
          before do
            stub_session(session_data: { user_return_to: new_subscriptions_path })
          end

          it 'redirects the user to the subscription page' do
            expect(patch_update).to redirect_to(new_subscriptions_path)
          end
        end

        context 'when no stored user value exists' do
          it 'redirects to the project dashboard page' do
            expect(patch_update).to redirect_to(dashboard_projects_path)
          end
        end
      end

      context 'when it is a failed request' do
        let(:update_params) { { user: { onboarding_status_role: onboarding_status_role } } }

        before do
          allow_next_instance_of(::Users::SubscriptionSignupService) do |service|
            allow(service).to receive(:execute).and_return(ServiceResponse.error(message: 'failed'))
          end
        end

        it 'does not track submission event' do
          patch_update

          expect_no_snowplow_event(
            category: 'registrations:subscription_welcome:update',
            action: 'successfully_submitted_form',
            user: user,
            label: 'subscription_registration'
          )
        end

        it 'track failed submission event' do
          patch_update

          expect_snowplow_event(
            category: 'registrations:subscription_welcome:update',
            action: 'track_subscription_registration_error',
            user: user,
            label: 'failed_submitting_form'
          )
        end
      end
    end
  end
end
