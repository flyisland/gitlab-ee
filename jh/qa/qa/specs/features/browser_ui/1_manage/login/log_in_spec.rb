# frozen_string_literal: true

module QA
  RSpec.describe 'JH Manage', :smoke, except: { tld: '.cn', subdomain: 'release' } do
    describe 'basic user login' do
      let(:user_with_phone) do
        Runtime::User::Store.test_user
      end

      it 'user logs in using phone number and logs out',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/1' do
        # HK environment does not support phone login, skip the phone check
        raise "Requires a user with phone number configured." if
          !Runtime::Env.hk_env? && user_with_phone.phone.blank?

        Flow::Login.sign_in(as: user_with_phone)

        Page::Main::Menu.perform do |menu|
          expect(menu).to have_personal_area
        end

        Support::Retrier.retry_until(sleep_interval: 0.5) do
          Page::Main::Menu.perform(&:sign_out)

          Page::Main::Login.perform(&:can_sign_in?)
        end

        Page::Main::Login.perform do |form|
          expect(form.can_sign_in?).to be(true)
        end
      end
    end
  end
end
