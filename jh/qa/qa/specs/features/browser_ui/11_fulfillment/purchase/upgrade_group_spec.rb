# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    describe 'Purchase' do
      describe 'group plan' do
        let(:admin_api_client) { Runtime::API::Client.as_admin }
        let(:ci_minutes) { 1000 }
        let(:premium_ci_minutes) { 10000 }
        let(:team_ci_minutes) { 2000 }
        let(:user) do
          Resource::User.fabricate_via_api! do |user|
            user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
            user.api_client = admin_api_client
            user.hard_delete_on_api_removal = true
          end
        end

        let(:group) do
          Resource::Sandbox.fabricate! do |sandbox|
            sandbox.path = "fulfillment-upgrade-plan-#{SecureRandom.hex(4)}"
          end
        end

        before do
          Flow::Login.sign_in(as: user)
          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
        end

        it 'upgrades from free to ultimate',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/52' do
          Flow::JhPurchase.purchase_subscription('ultimate')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Ultimate")).to be(true)
        end

        it 'upgrades from free to premium',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/53' do
          Flow::JhPurchase.purchase_subscription('premium')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Premium")).to be(true)
        end

        it 'upgrades from free to team',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/54' do
          Flow::JhPurchase.purchase_subscription('team')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Team")).to be(true)
        end

        it 'upgrades from trial to ultimate plan',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/51' do
          Page::Group::Settings::Billing.perform(&:go_to_free_trial)
          ::QA::Flow::JhTrial.start_trial(group.path, skip_select: true)
          ::QA::ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
            expect(free_trial_alert.trial_activated_message?)
              .to be(true)
          end

          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
          Flow::JhPurchase.upgrade_subscription('ultimate', from_trial: true)
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Ultimate")).to be(true)
        end

        it 'upgrades from trial to team plan',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/55' do
          Page::Group::Settings::Billing.perform(&:go_to_free_trial)
          ::QA::Flow::JhTrial.start_trial(group.path, skip_select: true)
          ::QA::ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
            expect(free_trial_alert.trial_activated_message?)
              .to be(true)
          end

          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
          Flow::JhPurchase.upgrade_subscription('team')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Team")).to be(true)
        end

        it 'upgrades from team to premium plan',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/76' do
          Flow::JhPurchase.purchase_subscription('team')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Team")).to be(true)

          Flow::JhPurchase.upgrade_subscription('premium')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Premium")).to be(true)
        end

        it 'upgrades from team to ultimate plan',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/77' do
          Flow::JhPurchase.purchase_subscription('team')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Team")).to be(true)

          Flow::JhPurchase.upgrade_subscription('ultimate')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Ultimate")).to be(true)
        end

        it 'upgrades from premium to ultimate plan',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/78' do
          Flow::JhPurchase.purchase_subscription('premium')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Premium")).to be(true)

          Flow::JhPurchase.upgrade_subscription('ultimate')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, "Ultimate")).to be(true)
        end

        context 'when with existing CI minutes pack' do
          let(:ci_minutes_quantity) { 5 }

          before do
            Resource::Project.fabricate_via_api! do |project|
              project.name = 'ci-minutes'
              project.group = group
              project.initialize_with_readme = true
              project.api_client = Runtime::API::Client.as_admin
            end

            Flow::JhPurchase.navigate_to_usage_quotas(group)
            Flow::JhPurchase.purchase_ci_minutes(ci_minutes_quantity)
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
          end

          it 'upgrades from free to premium with correct CI minutes',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/57' do
            Flow::JhPurchase.purchase_subscription('premium')
            Flow::JhPurchase.navigate_to_billing_page(group)

            expected_minutes = ci_minutes * ci_minutes_quantity
            plan_limits = premium_ci_minutes
            expect(Flow::JhPurchase.verify_purchase_successful(group, "Premium")).to be(true)

            Flow::JhPurchase.navigate_to_usage_quotas(group)
            Page::Group::Settings::UsageQuotas.perform do |usage_quotas|
              usage_quotas.switch_to_ci_minutes
              expect(usage_quotas.plan_ci_minutes).to eq(plan_limits.to_i)
              expect(usage_quotas.purchased_ci_minutes).to eq(expected_minutes.to_i)
            end
          end

          it 'upgrades from free to team with correct CI minutes',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/58' do
            Flow::JhPurchase.purchase_subscription('team')
            Flow::JhPurchase.navigate_to_billing_page(group)

            expected_minutes = ci_minutes * ci_minutes_quantity
            plan_limits = team_ci_minutes
            expect(Flow::JhPurchase.verify_purchase_successful(group, "Team")).to be(true)

            Flow::JhPurchase.navigate_to_usage_quotas(group)
            Page::Group::Settings::UsageQuotas.perform do |usage_quotas|
              usage_quotas.switch_to_ci_minutes
              expect(usage_quotas.plan_ci_minutes).to eq(plan_limits.to_i)
              expect(usage_quotas.purchased_ci_minutes).to eq(expected_minutes.to_i)
            end
          end
        end
      end
    end
  end
end
