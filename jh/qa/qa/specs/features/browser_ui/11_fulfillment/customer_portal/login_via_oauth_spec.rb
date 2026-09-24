# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke do
    shared_examples 'OAuth login to Customer Portal' do
      it 'signs in as the GitLab user' do
        Flow::JhCustomerPortal.sign_in(user: user)

        expect(ThirdPartyPage::CustomerPortal::Home.perform do |home|
          home.signed_in_as?(user)
        end).to be_truthy
      end
    end

    context 'with the existing user' do
      let(:user) { Runtime::User::Store.test_user }

      it_behaves_like 'OAuth login to Customer Portal'
    end

    context 'with a newly created user', :requires_admin, except: :production do
      let(:user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = Runtime::API::Client.as_admin
          resource.hard_delete_on_api_removal = true
        end
      end

      after do
        user.remove_via_api!
      end

      it_behaves_like 'OAuth login to Customer Portal'
    end
  end
end
