# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    let(:portal_admin) { Runtime::User::Store.test_user }
    let(:finance_user) do
      Resource::User.fabricate_via_api! do |resource|
        resource.api_client = Runtime::API::Client.as_admin
        resource.hard_delete_on_api_removal = true
      end
    end

    after do
      finance_user.remove_via_api!
    end

    it 'allows finance to view receivables' do
      # Create the user in Customer Portal before assigning the finance role.
      Flow::JhCustomerPortal.sign_in(user: finance_user)

      Flow::JhCustomerPortal.sign_in(user: portal_admin)
      ThirdPartyPage::CustomerPortal::Home.perform(&:open_access_control_users)
      ThirdPartyPage::CustomerPortal::AccessControlUsers.perform do |access_control|
        access_control.assign_finance_role(finance_user)
      end

      Flow::JhCustomerPortal.sign_in(user: finance_user)
      ThirdPartyPage::CustomerPortal::Home.perform(&:open_finance)

      expect(ThirdPartyPage::CustomerPortal::Finance.perform(&:statements_visible?)).to be_truthy
      expect(ThirdPartyPage::CustomerPortal::Home.perform do |home|
        home.signed_in_as?(finance_user)
      end).to be_truthy
    end
  end
end
