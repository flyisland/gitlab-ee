# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    describe 'Purchase' do
      describe 'group plan' do
        let(:admin_api_client) { Runtime::API::Client.as_admin }
        let(:max_seats_in_team_plan) { 10 }

        let(:user) do
          Resource::User.fabricate_via_api! do |user|
            user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
            user.api_client = admin_api_client
            user.hard_delete_on_api_removal = true
          end
        end

        let(:group) do
          Resource::Sandbox.fabricate! do |sandbox|
            sandbox.path = "fulfillment-purchase-limit-#{SecureRandom.hex(4)}"
            sandbox.visibility = 'private'
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

          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
        end

        context 'when purchase the team plan' do
          it 'exceeds the seats limit',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/56' do
            Page::Group::Settings::Billing.perform(&:go_to_purchase_team)
            Flow::JhPurchase.oauth_login_customerdot
            Flow::JhPurchase.fill_seat_quantity(max_seats_in_team_plan + 1)

            ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
              expect(subscription.seat_limit_content_valid?).to be(true)
            end
          end
        end
      end
    end
  end
end
