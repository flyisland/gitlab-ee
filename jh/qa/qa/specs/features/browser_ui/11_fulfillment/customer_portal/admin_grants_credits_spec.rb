# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    let(:admin_api_client) { Runtime::API::Client.as_admin }
    let(:portal_admin) { Runtime::User::Store.test_user }
    let(:credits_quantity) { 100 }
    let(:monthly_credits_quantity) { 1 }
    let(:user) do
      Resource::User.fabricate_via_api! do |resource|
        resource.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
        resource.api_client = admin_api_client
        resource.hard_delete_on_api_removal = true
      end
    end

    let(:group) do
      Resource::Sandbox.fabricate_via_api! do |resource|
        resource.api_client = admin_api_client
        resource.path = "portal-credit-grant-#{SecureRandom.hex(4)}"
        resource.visibility = 'private'
      end
    end

    before do
      group.add_member(user, Resource::Members::AccessLevel::OWNER)
      Flow::Login.sign_in(as: user)
      Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
    end

    after do
      user.remove_via_api!
    end

    shared_examples 'admin grants credits' do |quota_type, plan|
      it "allows an admin to grant #{quota_type} credits" do
        Flow::JhPurchase.purchase_subscription(plan)
        subscription_number = ThirdPartyPage::Customerdot::Subscription.perform(&:subscription_number)

        Flow::JhCustomerPortal.sign_in(user: portal_admin)
        ThirdPartyPage::CustomerPortal::Home.perform(&:open_subscriptions)
        ThirdPartyPage::CustomerPortal::Subscriptions.perform do |subscriptions|
          subscriptions.open_subscription(subscription_number)
          subscriptions.grant_credits(type: quota_type, amount: credits_quantity)

          expect(subscriptions.has_granted_credits?(
            type: quota_type,
            amount: credits_quantity,
            monthly_amount: monthly_credits_quantity
          )).to be_truthy
        end
      end
    end

    it_behaves_like 'admin grants credits', :prepaid, 'team'
    it_behaves_like 'admin grants credits', :postpaid, 'ultimate'
  end
end
