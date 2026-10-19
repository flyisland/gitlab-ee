# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    describe 'Purchase' do
      describe 'GitLab Credits' do
        let(:credits_quantity) { rand(100..200) }
        let(:admin_api_client) { Runtime::API::Client.as_admin }

        let(:user) do
          Resource::User.fabricate_via_api! do |user|
            user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
            user.api_client = admin_api_client
            user.hard_delete_on_api_removal = true
          end
        end

        after do
          user.remove_via_api!
        end

        context 'when purchasing GitLab Credits for free group',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/119' do
          let(:group) do
            Resource::Sandbox.fabricate! do |sandbox|
              sandbox.path = "fulfillment-purchase-credits-free-#{SecureRandom.hex(4)}"
              sandbox.visibility = 'private'
            end
          end

          before do
            Flow::Login.sign_in(as: user)
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
          end

          after do
            group.remove_via_api!
          end

          it 'completes the purchase successfully and displays credits on the page' do
            Flow::JhPurchase.purchase_credits(group, credits_quantity, source: :billing)
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)

            ::QA::Page::Group::Settings::Billing.perform do |billing|
              expect(billing.purchased_credits).to eq(credits_quantity)
            end
          end
        end

        context 'when purchasing GitLab Credits for trial group',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/120' do
          let(:group) do
            Resource::Sandbox.fabricate! do |sandbox|
              sandbox.path = "fulfillment-purchase-credits-trial-#{SecureRandom.hex(4)}"
              sandbox.visibility = 'private'
            end
          end

          before do
            Flow::Login.sign_in(as: user)
            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
          end

          after do
            group.remove_via_api!
          end

          it 'completes the trial subscription and credit purchase successfully' do
            ::QA::Page::Group::Settings::Billing.perform(&:go_to_free_trial)
            ::QA::Flow::JhTrial.start_trial(group.path, skip_select: true)

            ::QA::Page::Group::Settings::GitlabDuo.perform(&:go_to_gitlab_duo)
            ::QA::Page::Group::Settings::GitlabDuo.perform do |duo_config|
              expect(duo_config.gitlab_duo_configuration_settings_displayed?).to be(true)
            end

            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
            Flow::JhPurchase.purchase_credits(group, credits_quantity, source: :billing)

            Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
            ::QA::Page::Group::Settings::Billing.perform do |billing|
              expect(billing.purchased_credits).to eq(credits_quantity)
            end
          end
        end

        shared_examples 'purchasing credits for a paid plan' do |plan_name, testcase_id|
          context "when purchasing GitLab Credits for #{plan_name} plan",
            testcase: "https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/#{testcase_id}" do
            let(:group) do
              Resource::Sandbox.fabricate! do |sandbox|
                sandbox.path = "fulfillment-purchase-credits-#{plan_name}-#{SecureRandom.hex(4)}"
                sandbox.visibility = 'private'
              end
            end

            before do
              Flow::Login.sign_in(as: user)
              Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
              Flow::JhPurchase.purchase_subscription(plan_name)
              Flow::JhPurchase.navigate_to_billing_page(group)
            end

            it 'completes the subscription purchase and credit purchase successfully' do
              expect(Flow::JhPurchase.verify_purchase_successful(group, plan_name.capitalize)).to be(true)

              ::QA::Page::Group::Settings::GitlabDuo.perform(&:go_to_gitlab_duo)
              ::QA::Page::Group::Settings::GitlabDuo.perform do |duo_config|
                expect(duo_config.gitlab_duo_configuration_settings_displayed?).to be(true)
              end

              Flow::JhPurchase.purchase_credits(group, credits_quantity)

              ::QA::ThirdPartyPage::Customerdot::Subscription.perform(&:wait_for_redirect_to_customers_portal)

              ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
                subscription.switch_language('en')
                expect(subscription.verify_monthly_credits_details(credits_quantity)).to be true
              end
            end
          end
        end

        it_behaves_like 'purchasing credits for a paid plan', 'team', '123'
        it_behaves_like 'purchasing credits for a paid plan', 'premium', '122'
        it_behaves_like 'purchasing credits for a paid plan', 'ultimate', '121'
      end
    end
  end
end
