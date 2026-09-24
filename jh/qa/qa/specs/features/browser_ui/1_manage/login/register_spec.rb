# frozen_string_literal: true

module QA
  RSpec.describe 'JH Manage', :smoke, only: { subdomain: :staging } do
    describe 'User Registration' do
      let(:user) do
        Resource::User.init do |user|
          user.username = "qa-user-#{SecureRandom.hex(6)}"
          user.password = "TestPassword#{SecureRandom.hex(4)}!"
          user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
        end
      end

      it 'registers with email', testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/75' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)
        Flow::JhSignUp.sign_up_with_email(user)

        Page::Registration::JhWelcome.perform do |welcome|
          expect(welcome).to have_continue_button(wait: 30)
        end
      end
    end
  end
end
