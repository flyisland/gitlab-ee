# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment',
    :smoke,
    :requires_admin,
    only: { subdomain: :staging, tld: '.com' },
    feature_category: :subscription_management do
    include Support::API

    let(:admin_api_client) { Runtime::API::Client.as_admin }

    let(:customer) do
      Resource::User.fabricate_via_api! do |resource|
        resource.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
        resource.api_client = admin_api_client
        resource.hard_delete_on_api_removal = true
      end
    end

    let(:group) do
      Resource::Sandbox.fabricate_via_api! do |resource|
        resource.api_client = admin_api_client
        resource.path = "portal-subscription-#{SecureRandom.hex(4)}"
        resource.visibility = 'private'
      end
    end

    after do
      customer.remove_via_api!
    end

    describe 'Customer Portal API' do
      it 'allows a customer to view their subscriptions' do
        group.add_member(customer, Resource::Members::AccessLevel::OWNER)

        Flow::Login.sign_in(as: customer)
        Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
        Flow::JhPurchase.purchase_subscription('team')

        subscription_number = ThirdPartyPage::Customerdot::Subscription.perform(&:subscription_number)
        cookies = sign_in_as_customer

        list_response = portal_get('/my/subscriptions.json', cookies: cookies)
        expect(list_response.code).to eq(Support::API::HTTP_STATUS_OK)

        list_body = parse_body(list_response)
        expect(list_body.fetch(:meta)).to include(mappingFound: true)
        expect(list_body.fetch(:subscriptions)).to include(
          a_hash_including(subscriptionNumber: subscription_number)
        )

        subscription = list_body.fetch(:subscriptions).find do |item|
          item.fetch(:subscriptionNumber) == subscription_number
        end

        detail_response = portal_get(
          "/my/subscriptions/#{subscription.fetch(:id)}.json",
          cookies: cookies
        )
        expect(detail_response.code).to eq(Support::API::HTTP_STATUS_OK)

        expect(parse_body(detail_response).fetch(:subscription)).to include(
          id: subscription.fetch(:id),
          subscriptionNumber: subscription_number
        )
      end

      it 'enforces authentication and customer role boundaries' do
        unauthenticated_response = portal_get('/my/subscriptions.json')

        expect(unauthenticated_response.code).to eq(Support::API::HTTP_STATUS_UNAUTHORIZED)
        expect(parse_body(unauthenticated_response)).to eq(error: 'unauthenticated')

        cookies = sign_in_as_customer

        customer_response = portal_get('/my/subscriptions.json', cookies: cookies)
        expect(customer_response.code).to eq(Support::API::HTTP_STATUS_OK)
        expect(parse_body(customer_response).fetch(:subscriptions)).to be_empty

        management_response = portal_get('/manage/jihulab/subscriptions.json', cookies: cookies)

        expect(management_response.code).to eq(403)
        expect(parse_body(management_response)).to eq(error: 'forbidden')
      end
    end

    private

    def sign_in_as_customer
      Flow::JhCustomerPortal.sign_in(user: customer)

      cookie = Capybara.current_session.driver.browser.manage.cookie_named('_jh_customer_portal_session')

      raise 'Customer Portal session cookie was not found' unless cookie

      { cookie.fetch(:name) => cookie.fetch(:value) }
    end

    def portal_get(path, cookies: {})
      base_url = Runtime::Env.customer_portal_url.delete_suffix('/')

      Support::API.get(
        "#{base_url}#{path}",
        headers: { accept: :json },
        cookies: cookies,
        verify_ssl: true
      )
    end
  end
end
