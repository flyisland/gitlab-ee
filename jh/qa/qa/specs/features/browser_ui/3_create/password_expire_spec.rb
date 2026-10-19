# frozen_string_literal: true

module QA
  RSpec.describe 'JH Create', :smoke, :require_admin do
    describe 'Password expire' do
      let(:expire_in_days_data) { Page::Settings::PasswordExpire.perform(&:get_expire_in_days_value) }
      let(:expire_notify_data) { Page::Settings::PasswordExpire.perform(&:get_expire_notify_value) }

      before do
        Runtime::ApplicationSettings.set_application_settings(password_expiration_enabled: true)
        Flow::Login.sign_in_as_admin
        Page::Main::Menu.perform(&:go_to_admin_area)
        Page::Admin::Menu.perform(&:go_to_general_settings)
        Page::Admin::Settings::General.perform(&:expand_account_and_limit)
        expire_in_days_data
        expire_notify_data
      end

      after do
        Page::Settings::PasswordExpire.perform do |password_expire|
          password_expire.set_up_password_expire_value(expire_in_days_data, expire_notify_data)
        end
        Runtime::ApplicationSettings.set_application_settings(password_expiration_enabled: false)
      end

      it 'after setting a valid value can be saved successfully',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/68' do
        Page::Settings::PasswordExpire.perform do |set_up_valid_value|
          set_up_valid_value.set_up_password_expire_value('90', '7')
        end
        Page::Settings::PasswordExpire.perform do |save_successfully_tips|
          expect(save_successfully_tips).to have_notice("Application settings saved successfully")
        end
      end

      it 'update failed after setting an invalid value',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/67' do
        Page::Settings::PasswordExpire.perform do |set_up_invalid_value|
          set_up_invalid_value.set_up_password_expire_value('401', '31')
        end
        Page::Settings::PasswordExpire.perform do |save_failed_tips|
          expect(save_failed_tips).to have_notice('Application settings update failed')
        end
      end
    end
  end
end
