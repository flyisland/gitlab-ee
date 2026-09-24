# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :require_admin, only: { subdomain: :staging } do
    describe 'Purchase' do
      let(:api_client) { Runtime::API::Client.as_admin }

      let(:user) do
        Resource::User.fabricate_via_api! do |user|
          user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
          user.api_client = api_client
          user.hard_delete_on_api_removal = true
        end
      end

      let(:group_for_trial) do
        Resource::Sandbox.fabricate! do |sandbox|
          sandbox.path = "fulfillment-free-trial-#{SecureRandom.hex(4)}"
          sandbox.api_client = api_client
        end
      end

      before do
        Flow::Login.sign_in(as: user)
      end

      describe 'Free Trial Process' do
        context 'when a user initiates a normal group trial' do
          before do
            Flow::JhPurchase.navigate_to_billing_page(group_for_trial, plan_exists: false)
          end

          it 'displays the correct ultimate trial duration',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/69' do
            Page::Group::Settings::Billing.perform(&:go_to_free_trial)
            ::QA::Flow::JhTrial.start_trial(group_for_trial.path, skip_select: true)

            ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
              expect(free_trial_alert.trial_activated_message?).to be(true)
            end

            Page::Group::Trial::TrialCard.perform do |trial_info|
              expect(trial_info.has_group_trial_duration_card?).to be(true)
              expect(trial_info.has_upgrade_button?).to be(true)
              expect(trial_info.has_explore_button?).to be(true)
            end
          end
        end

        context 'when on billing page with multiple eligible namespaces' do
          let!(:group) do
            Resource::Sandbox.fabricate! do |sandbox|
              sandbox.path = "fulfillment-free-trial-#{SecureRandom.hex(4)}"
              sandbox.api_client = api_client
            end
          end

          before do
            Flow::JhPurchase.navigate_to_billing_page(group_for_trial, plan_exists: false)
          end

          it 'registers for a new trial',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/3' do
            Page::Group::Settings::Billing.perform(&:go_to_free_trial)

            ::QA::Flow::JhTrial.start_trial(group_for_trial.path)
            ::QA::ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
              expect(free_trial_alert.trial_activated_message?).to be(true)
            end

            Page::Group::Menu.perform(&:go_to_billing)
            Flow::JhTrial.verify_trial_success
          end
        end

        context 'when on billing page with only one eligible namespace' do
          before do
            Flow::JhPurchase.navigate_to_billing_page(group_for_trial, plan_exists: false)
          end

          it 'registers for a new trial',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/16' do
            Page::Group::Settings::Billing.perform(&:go_to_free_trial)
            ::QA::Flow::JhTrial.start_trial(group_for_trial.path, skip_select: true)

            ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
              expect(free_trial_alert.trial_activated_message?).to be(true)
            end

            Page::Group::Menu.perform(&:go_to_billing)
            Flow::JhTrial.verify_trial_success
          end
        end

        context 'with a newly registered user' do
          before do
            visit_free_trial_from_learning_page(group_for_trial.id)
          end

          it 'registers for a new trial',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/20' do
            ::QA::Flow::JhTrial.start_trial(skip_select: true)

            ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
              expect(free_trial_alert.trial_activated_message?).to be(true)
            end

            Page::Group::Menu.perform(&:go_to_billing)
            Flow::JhTrial.verify_trial_success
          end
        end

        private

        # rubocop:disable Layout/LineLength -- the url is longer than the line limit
        def visit_free_trial_from_learning_page(namespace_id)
          visit "#{Runtime::Env.gitlab_url}/-/trials/new?glm_content=onboarding-start-trial&glm_source=gitlab.com&namespace_id=#{namespace_id}"
        end
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
