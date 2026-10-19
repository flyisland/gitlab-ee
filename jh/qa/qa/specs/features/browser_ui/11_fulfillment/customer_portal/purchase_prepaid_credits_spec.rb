# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin,
    only: { subdomain: :staging, tld: '.com' } do
    let(:admin_api_client) { Runtime::API::Client.as_admin }
    let(:credits_quantity) { 500 }
    let(:monthly_credits_quantity) { 100 }
    let(:projects_to_remove) { [] }

    let(:user) do
      Resource::User.fabricate_via_api! do |resource|
        resource.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
        resource.api_client = admin_api_client
        resource.hard_delete_on_api_removal = true
      end
    end

    let(:group) do
      Resource::Sandbox.fabricate_via_api! do |resource|
        resource.path = "portal-prepaid-credits-#{SecureRandom.hex(4)}"
        resource.visibility = 'private'
        resource.api_client = admin_api_client
      end
    end

    let(:subscription_number) do
      ThirdPartyPage::Customerdot::Subscription.perform(&:subscription_number)
    end

    before do
      group.add_member(user, Resource::Members::AccessLevel::OWNER)
      Flow::Login.sign_in(as: user)
      Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
    end

    after do
      projects_to_remove.each(&:remove_via_api!)
      user.remove_via_api!
    end

    describe 'Purchase prepaid credits through Customer Portal' do
      context 'for a Team plan group' do
        before do
          Flow::JhPurchase.purchase_subscription('team')
        end

        it 'purchases prepaid credits and updates the balance' do
          open_portal_subscription

          ThirdPartyPage::CustomerPortal::MySubscriptions.perform do |subscriptions|
            expect(subscriptions.has_no_prepaid_credits?).to be(true)
          end

          Flow::JhCustomerPortal.purchase_prepaid_credits(credits_quantity)

          ThirdPartyPage::CustomerPortal::MySubscriptions.perform do |subscriptions|
            expect(subscriptions.has_prepaid_credits?(credits_quantity)).to be(true)
          end
        end
      end

      context 'for a group with monthly credits' do
        before do
          Flow::JhPurchase.purchase_credits(group, monthly_credits_quantity, source: :billing)

          subscription_number
          Page::Group::Settings::UsageQuotas.perform(&:close_window)
        end

        it 'purchases prepaid credits without changing the monthly credits' do
          open_portal_subscription

          ThirdPartyPage::CustomerPortal::MySubscriptions.perform do |subscriptions|
            expect(subscriptions.has_monthly_credits?(monthly_credits_quantity)).to be(true)
            expect(subscriptions.has_no_prepaid_credits?).to be(true)
          end

          Flow::JhCustomerPortal.purchase_prepaid_credits(credits_quantity)

          ThirdPartyPage::CustomerPortal::MySubscriptions.perform do |subscriptions|
            expect(subscriptions.has_prepaid_credits?(credits_quantity)).to be(true)
            expect(subscriptions.has_monthly_credits?(monthly_credits_quantity)).to be(true)
          end
        end
      end

      context 'for an Ultimate plan group', :external_api_calls, :external_ai_provider do
        before do
          Flow::JhPurchase.purchase_subscription('ultimate')
        end

        it 'allows the user to use Duo Chat after purchasing prepaid credits' do
          open_portal_subscription

          ThirdPartyPage::CustomerPortal::MySubscriptions.perform do |subscriptions|
            expect(subscriptions.has_no_prepaid_credits?).to be(true)
          end

          Flow::JhCustomerPortal.purchase_prepaid_credits(credits_quantity)

          ThirdPartyPage::CustomerPortal::MySubscriptions.perform do |subscriptions|
            expect(subscriptions.has_prepaid_credits?(credits_quantity)).to be(true)
          end

          project = create(:project,
            :with_readme,
            name: "portal-prepaid-duo-#{SecureRandom.hex(4)}",
            group: group,
            api_client: admin_api_client)
          projects_to_remove << project

          project.visit!

          Page::Component::DuoAgentPlatform.perform(&:wait_for_chat_available)

          response = Flow::JhCredits.consume_with_chat(
            '请以“我是 GitLab Duo Chat”开头，用中文列出你的至少 5 项主要能力，' \
              '每项包含一个具体使用场景，并在结尾用一句话总结。'
          )

          expect(response).to include('我是 GitLab Duo Chat')
        end
      end
    end

    private

    def open_portal_subscription
      number = subscription_number

      Flow::JhCustomerPortal.sign_in(user: user)
      ThirdPartyPage::CustomerPortal::Home.perform(&:open_my_subscriptions)
      ThirdPartyPage::CustomerPortal::MySubscriptions.perform do |subscriptions|
        subscriptions.open_subscription(number)
      end
    end
  end
end
