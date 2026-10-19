# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::TrialsController, :saas, feature_category: :plan_provisioning do
  include SubscriptionPortalHelpers

  let_it_be(:user, reload: true) { create(:user) }
  let(:glm_params) { { glm_source: '_glm_source_', glm_content: '_glm_content_' } }
  let(:subscriptions_trials_enabled) { true }

  before do
    stub_saas_features(subscriptions_trials: subscriptions_trials_enabled, marketing_google_tag_manager: false)
    stub_subscription_trial_types
    stub_feature_flags(ultimate_trial_with_dap: false)
  end

  describe 'GET new' do
    let(:namespace_id) { {} }
    let(:base_params) { glm_params.merge(namespace_id) }

    subject(:get_new) do
      get new_trial_path, params: base_params
      response
    end

    context 'when authenticated' do
      before do
        login_as(user)
      end

      it { is_expected.to have_gitlab_http_status(:ok) }

      context 'when user has a temporary email', :phone_verification_code_enabled do
        let(:phone_without_area_code) { '15612341234' }

        let(:user) do
          create(
            :user,
            email: "temp-email-for-phone-#{SecureRandom.uuid}@gitlab.localhost",
            phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt("+86#{phone_without_area_code}")
          )
        end

        it 'redirects to the profile page' do
          expect(get_new).to redirect_to(user_settings_profile_path(redirected: true))
        end

        context 'when the feature flag is disabled' do
          before do
            stub_feature_flags(jh_redirect_trial_temp_email_to_profile: false)
          end

          it { is_expected.to have_gitlab_http_status(:ok) }
        end
      end
    end
  end

  describe 'POST create' do
    let_it_be(:group_for_trial, reload: true) { create(:group_with_plan, plan: :free_plan, owners: user) }
    let(:step) { 'full' }
    let(:namespace_id) { { namespace_id: group_for_trial.id.to_s } }
    let(:lead_params) do
      {
        company_name: '_company_name_',
        first_name: '_first_name_',
        last_name: '_last_name_',
        phone_number: '123',
        country: '_country_',
        state: '_state_'
      }.with_indifferent_access
    end

    let(:trial_params) { namespace_id.with_indifferent_access }
    let(:base_params) { lead_params.merge(trial_params).merge(glm_params).merge(step: step) }

    subject(:post_create) do
      post trials_path, params: base_params
      response
    end

    context 'when authenticated', :use_clean_rails_memory_store_caching do
      before do
        Rails.cache.write(
          "namespaces:eligible_trials:#{group_for_trial.id}", [GitlabSubscriptions::Trials::FREE_TRIAL_TYPE]
        )
        allow(GitlabSubscriptions::Trials).to receive(:eligible_namespaces_for_user).with(user)
          .and_return(Group.id_in(group_for_trial.id))
        login_as(user)
      end

      context 'when successful' do
        let_it_be(:add_on) { create(:gitlab_subscription_add_on, :duo_enterprise) }
        let_it_be(:ultimate_trial_plan) { create(:ultimate_trial_plan) }

        let(:add_on_purchase) do
          build(:gitlab_subscription_add_on_purchase, expires_on: 60.days.from_now)
        end

        context 'for basic success cases' do
          before do
            expect_create_success(group_for_trial)
          end

          it { is_expected.to redirect_to(group_path(group_for_trial)) }

          it 'shows valid flash message', :freeze_time do
            post_create

            message = format(
              _(
                'You have successfully started a GitLab Ultimate trial that will ' \
                  'expire on %{exp_date}.'
              ),
              exp_date: I18n.l(group_for_trial.gitlab_subscription.end_date, format: :long)
            )
            expect(flash[:success]).to have_content(message)
          end

          # upstream code
          # it { is_expected.to redirect_to(group_settings_gitlab_duo_path(group_for_trial)) }

          # it 'shows valid flash message', :freeze_time do
          #   post_create

          #   message = format(
          #     s_(
          #       'BillingPlans|You have successfully started an Ultimate and GitLab Duo Enterprise trial that will ' \
          #         'expire on %{exp_date}.'
          #     ),
          #     exp_date: I18n.l(60.days.from_now.to_date, format: :long)
          #   )
          #   expect(flash[:success]).to have_content(message)
          # end
        end
      end
    end

    def update_with_applied_trials(namespace)
      namespace.gitlab_subscription.update!(
        hosted_plan: ultimate_trial_plan,
        trial: true,
        trial_starts_on: Time.current,
        trial_ends_on: Time.current + 60.days
      )
    end

    def expect_create_success(namespace)
      service_params = {
        step: step,
        params: trial_params.merge(lead_params, glm_params, organization_id: anything),
        user: user
      }

      expect_next_instance_of(GitlabSubscriptions::Trials::UltimateCreateService, service_params) do |instance|
        expect(instance).to receive(:execute) do
          update_with_applied_trials(namespace)
        end.and_return(
          ServiceResponse.success(payload: { namespace: namespace, add_on_purchase: add_on_purchase })
        )
      end
    end
  end
end
