# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke do
    RSpec.shared_examples 'check profile' do
      it 'profile page should has users information area' do
        ::QA::ThirdPartyPage::Customerdot::Landingpage.perform(&:go_to_profile)
        ::QA::ThirdPartyPage::Customerdot::Profile.perform do |profile|
          expect(profile.has_user_information_area?).to be_truthy
        end
        ::QA::ThirdPartyPage::Customerdot::Landingpage.perform(&:sign_out)
      end
    end

    let(:customerdot_url) { Runtime::Env.customerdot_url }
    let(:api_client) { Runtime::API::Client.as_admin }
    let(:register_email) { "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn" }

    let(:user) do
      Resource::User.fabricate_via_api! do |user|
        user.email = register_email
        user.api_client = api_client
        user.hard_delete_on_api_removal = true
      end
    end

    context "as existed user login customerdot",
      testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/36' do
      before do
        visit(customerdot_url)
        ::QA::ThirdPartyPage::Customerdot::Signin.perform(&:login)
      end

      after do
        Page::Main::Menu.perform(&:sign_out)
      end

      it_behaves_like 'check profile'
    end

    context "as new user login customer", :require_admin, except: :production,
      testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/37' do
      before do
        visit(customerdot_url)
        ::QA::ThirdPartyPage::Customerdot::Signin.perform do |sign_in|
          sign_in.login(user: user)
        end
      end

      after do
        user.remove_via_api!
      end

      it_behaves_like 'check profile'
    end
  end
end
