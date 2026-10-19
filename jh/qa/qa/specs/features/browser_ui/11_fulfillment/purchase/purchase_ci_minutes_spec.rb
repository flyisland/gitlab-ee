# frozen_string_literal: true

module QA
  include QA::Support::Helpers::Plan
  # Todo: Automation https://jihulab.com/gitlab-cn/internal/customers-jihulab-com/-/issues/208
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    context 'when Purchase CI minutes' do
      # the quantity of products to purchase
      let(:purchase_quantity) { 5 }
      let(:team_ci_minutes) { 2000 }
      let(:compute_minutes) { 1000 }
      let(:ultimate_compute_minutes) { 50000 }

      let(:user) do
        Resource::User.fabricate_via_api! do |user|
          user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
          user.api_client = Runtime::API::Client.as_admin
          user.hard_delete_on_api_removal = true
        end
      end

      let(:group) do
        Resource::Sandbox.fabricate! do |sandbox|
          sandbox.path = "fulfillment-purchase-ci-#{SecureRandom.hex(4)}"
          sandbox.api_client = Runtime::API::Client.as_admin
        end
      end

      before do
        Flow::Login.sign_in(as: user)

        # A group project is required for additional CI Minutes to show up
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'ci-minutes'
          project.group = group
          project.initialize_with_readme = true
          project.api_client = Runtime::API::Client.as_admin
        end
      end

      context 'when without active subscription' do
        before do
          Flow::JhPurchase.navigate_to_usage_quotas(group)
        end

        it 'adds additional minutes to group namespace',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/50' do
          Flow::JhPurchase.purchase_ci_minutes(purchase_quantity)

          Flow::JhPurchase.navigate_to_usage_quotas(group)
          ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
            expected_minutes = compute_minutes * purchase_quantity
            usage_quota.switch_to_ci_minutes
            expect(usage_quota.purchased_ci_minutes).to be(expected_minutes.to_i)
          end
        end
      end

      context 'with an active subscription' do
        before do
          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
        end

        it 'adds additional minutes to group under the ultimate plan',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/49' do
          Flow::JhPurchase.purchase_subscription('ultimate')

          Flow::JhPurchase.navigate_to_usage_quotas(group)
          Flow::JhPurchase.purchase_ci_minutes(purchase_quantity)

          Flow::JhPurchase.navigate_to_usage_quotas(group)
          ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
            expected_minutes = compute_minutes * purchase_quantity
            plan_limits = ultimate_compute_minutes

            usage_quota.switch_to_ci_minutes
            expect(usage_quota.purchased_ci_minutes).to eq(expected_minutes.to_f)
            expect(usage_quota.plan_ci_minutes).to eq(plan_limits.to_f)
          end
        end

        it 'adds additional minutes to group under the team plan',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/48' do
          Flow::JhPurchase.purchase_subscription('team')

          Flow::JhPurchase.navigate_to_usage_quotas(group)
          Flow::JhPurchase.purchase_ci_minutes(purchase_quantity)

          Flow::JhPurchase.navigate_to_usage_quotas(group)
          ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
            expected_minutes = compute_minutes * purchase_quantity
            plan_limits = team_ci_minutes

            usage_quota.switch_to_ci_minutes
            expect(usage_quota.purchased_ci_minutes).to eq(expected_minutes.to_f)
            expect(usage_quota.plan_ci_minutes).to eq(plan_limits.to_f)
          end
        end
      end

      context 'with existing CI minutes packs' do
        before do
          Flow::JhPurchase.navigate_to_usage_quotas(group)
          Flow::JhPurchase.purchase_ci_minutes(purchase_quantity)
        end

        after do
          group.remove_via_api!
        end

        it 'adds additional minutes to group namespace',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/46' do
          Flow::JhPurchase.navigate_to_usage_quotas(group)
          Flow::JhPurchase.purchase_ci_minutes(purchase_quantity)

          Flow::JhPurchase.navigate_to_usage_quotas(group)
          ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
            expected_minutes = compute_minutes * purchase_quantity * 2
            usage_quota.switch_to_ci_minutes
            expect(usage_quota.purchased_ci_minutes).to be(expected_minutes.to_i)
          end
        end
      end

      context 'with a trial user' do
        before do
          ::QA::Page::Group::Menu.perform(&:go_to_billing)
          Page::Group::Settings::Billing.perform(&:go_to_free_trial)
          ::QA::Flow::JhTrial.start_trial(group.path, skip_select: true)

          Flow::JhPurchase.navigate_to_usage_quotas(group)
        end

        it 'adds additional minutes to group namespace',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/47' do
          Flow::JhPurchase.purchase_ci_minutes(purchase_quantity)

          Flow::JhPurchase.navigate_to_usage_quotas(group)
          ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
            expected_minutes = compute_minutes * purchase_quantity
            plan_limits = FREE[:compute_minutes]

            usage_quota.switch_to_ci_minutes
            expect(usage_quota.purchased_ci_minutes).to eq(expected_minutes.to_f)
            expect(usage_quota.plan_ci_minutes).to eq(plan_limits.to_f)
          end
        end
      end
    end
  end
end
