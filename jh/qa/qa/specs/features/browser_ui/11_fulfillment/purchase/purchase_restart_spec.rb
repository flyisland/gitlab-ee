# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    describe 'Purchase' do
      describe 'restart purchase process' do
        let(:admin_api_client) { Runtime::API::Client.as_admin }
        let(:purchase_ci_minutes_quantity) { 5 }
        let(:base_minutes) { 1000 }
        let(:storage) { 10 }
        let(:purchase_storage_quantity) { 5 }

        let(:user) do
          Resource::User.fabricate_via_api! do |user|
            user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
            user.api_client = admin_api_client
            user.hard_delete_on_api_removal = true
          end
        end

        let(:group) do
          Resource::Sandbox.fabricate! do |sandbox|
            sandbox.path = "fulfillment-purchase-restart-#{SecureRandom.hex(4)}"
          end
        end

        before do
          Flow::Login.sign_in(as: user)

          # A group project is required for additional to show up
          Resource::Project.fabricate_via_api! do |project|
            project.name = 'purchase-test-project'
            project.group = group
            project.initialize_with_readme = true
            project.api_client = Runtime::API::Client.as_admin
          end
        end

        after(:each, :reset_plan) do
          Flow::Login.sign_in_as_admin
          Page::Admin::Groups::Index.perform do |index|
            index.edit_group_subscription(group.name, 'No plan')
          end
        end

        context 'when group is on free plan' do
          it 'can restart purchase plan process', :reset_plan,
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/71' do
            # first purchase, no payment
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
            Flow::JhPurchase.purchase_subscription('premium', skip_payment: true)

            # return to the billing page and complete the purchase again
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
            Flow::JhPurchase.purchase_subscription('premium')

            Flow::JhPurchase.navigate_to_billing_page(group)
            expect(Flow::JhPurchase.verify_purchase_successful(group, "Premium")).to be(true)
          end

          it 'can restart purchase storage process',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/73' do
            # first purchase, no payment
            Flow::JhPurchase.navigate_to_usage_quotas(group)
            Flow::JhPurchase.purchase_storage(purchase_storage_quantity, skip_payment: true)

            # return to the billing page and complete the purchase again
            Flow::JhPurchase.navigate_to_usage_quotas(group)
            Flow::JhPurchase.purchase_storage(purchase_storage_quantity)

            Flow::JhPurchase.navigate_to_usage_quotas(group)
            QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
              expected_storage = (storage * purchase_storage_quantity) + Runtime::Env.default_storage.to_f

              usage_quota.switch_to_storage
              Support::Waiter.wait_until(max_duration: 120, reload_page: page, raise_on_failure: false) do
                expect(usage_quota.purchased_storage).to eq(expected_storage)
              end
            end
          end

          it 'can restart purchase ci_minutes process',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/74' do
            # first purchase, no payment
            Flow::JhPurchase.navigate_to_usage_quotas(group)
            Flow::JhPurchase.purchase_ci_minutes(purchase_ci_minutes_quantity, skip_payment: true)

            # return to the billing page and complete the purchase again
            Flow::JhPurchase.navigate_to_usage_quotas(group)
            Flow::JhPurchase.purchase_ci_minutes(purchase_ci_minutes_quantity)

            Flow::JhPurchase.navigate_to_usage_quotas(group)
            ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
              expected_minutes = base_minutes * purchase_ci_minutes_quantity
              usage_quota.switch_to_ci_minutes
              expect(usage_quota.purchased_ci_minutes).to eq(expected_minutes.to_i)
            end
          end
        end

        context 'when group is on trial plan' do
          it 'can restart purchase plan process during trial', :reset_plan,
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/72' do
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
            Page::Group::Settings::Billing.perform(&:go_to_free_trial)
            ::QA::Flow::JhTrial.start_trial(group.path, skip_select: true)

            ::QA::ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
              expect(free_trial_alert.trial_activated_message?).to be(true)
            end

            # first purchase, no payment
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
            Flow::JhPurchase.upgrade_subscription('ultimate', from_trial: true, skip_payment: true)

            # return to the payment page and complete the purchase again
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
            Flow::JhPurchase.upgrade_subscription('ultimate', from_trial: true)

            Flow::JhPurchase.navigate_to_billing_page(group)
            expect(Flow::JhPurchase.verify_purchase_successful(group, "Ultimate")).to be(true)
          end
        end
      end
    end
  end
end
