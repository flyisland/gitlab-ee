# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    describe 'Purchase' do
      describe 'additional GitLab Credits' do
        let(:initial_credits_quantity) { 100 }
        let(:additional_credits_quantity) { 50 }
        let(:expected_credits_quantity) { initial_credits_quantity + additional_credits_quantity }
        let(:monthly_price_per_credit) { 1 }
        let(:subscription_term_months) { 12 }
        let(:admin_api_client) { Runtime::API::Client.as_admin }
        let(:remove_group_after_test) { true }

        let(:user) do
          Resource::User.fabricate_via_api! do |user|
            user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
            user.api_client = admin_api_client
            user.hard_delete_on_api_removal = true
          end
        end

        let(:group) do
          Resource::Sandbox.fabricate! do |sandbox|
            sandbox.path = "fulfillment-purchase-additional-credits-#{SecureRandom.hex(4)}"
            sandbox.visibility = 'private'
          end
        end

        before do
          Flow::Login.sign_in(as: user)
          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
        end

        after do
          group.remove_via_api! if remove_group_after_test
          user.remove_via_api!
        end

        it 'adds purchased credits to the existing credits',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/124' do
          Flow::JhPurchase.purchase_credits(group, initial_credits_quantity, source: :billing) do |subscription|
            expect(subscription.total_amount).to eq(expected_purchase_amount(initial_credits_quantity))
          end

          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)

          ::QA::Page::Group::Settings::Billing.perform do |billing|
            expect(billing.purchased_credits).to eq(initial_credits_quantity)
          end

          Flow::JhPurchase.purchase_credits(group, additional_credits_quantity, source: :billing) do |subscription|
            expect(subscription.total_amount).to eq(expected_purchase_amount(additional_credits_quantity))
          end

          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)

          ::QA::Page::Group::Settings::Billing.perform do |billing|
            expect(billing.purchased_credits).to eq(expected_credits_quantity)
          end
        end

        context 'for a Premium plan group' do
          let(:remove_group_after_test) { false }

          it 'adds purchased credits to the existing credits',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/125' do
            Flow::JhPurchase.purchase_subscription('premium')
            Flow::JhPurchase.navigate_to_billing_page(group)
            expect(Flow::JhPurchase.verify_purchase_successful(group, 'Premium')).to be(true)

            ::QA::Page::Group::Settings::GitlabDuo.perform(&:go_to_gitlab_duo)
            Flow::JhPurchase.purchase_credits(group, initial_credits_quantity) do |subscription|
              expect(subscription.total_amount).to eq(expected_purchase_amount(initial_credits_quantity))
            end

            ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
              subscription.wait_for_redirect_to_customers_portal
              subscription.switch_language('en')
              subscription.go_to_gitlab_credits_dashboard
              expect(subscription.verify_monthly_credits_dashboard(initial_credits_quantity)).to be(true)
            end
            ::QA::Page::Group::Settings::UsageQuotas.perform(&:close_window)

            Flow::JhPurchase.navigate_to_billing_page(group)
            ::QA::Page::Group::Settings::GitlabDuo.perform(&:go_to_gitlab_duo)
            Flow::JhPurchase.purchase_credits(group, additional_credits_quantity) do |subscription|
              expect(subscription.total_amount).to eq(expected_purchase_amount(additional_credits_quantity))
            end

            ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
              subscription.wait_for_redirect_to_customers_portal
              subscription.switch_language('en')
              subscription.go_to_gitlab_credits_dashboard
              expect(subscription.verify_monthly_credits_dashboard(expected_credits_quantity)).to be(true)
            end
            ::QA::Page::Group::Settings::UsageQuotas.perform(&:close_window)
          end
        end

        private

        def expected_purchase_amount(credits_quantity)
          credits_quantity * monthly_price_per_credit * subscription_term_months
        end
      end
    end
  end
end
