# frozen_string_literal: true

module QA
  module Page
    module Settings
      class PasswordExpire < QA::Page::Base
        include Layout::Flash

        view 'jh/app/assets/javascripts/admin/application_settings/password_expiration/components/app.vue' do
          element 'expire-in-days-field'
          element 'expire-notify-field'
        end

        view 'app/assets/javascripts/pages/admin/application_settings/general/components/signup_form.vue' do
          element 'save-changes-button'
        end

        def set_up_password_expire_value(expire_in_days_value, expire_notify_value)
          fill_element('expire-in-days-field', expire_in_days_value)
          fill_element('expire-notify-field', expire_notify_value)
          click_element('save-changes-button')
        end

        def get_expire_in_days_value
          find_element('expire-in-days-field').value
        end

        def get_expire_notify_value
          find_element('expire-notify-field').value
        end
      end
    end
  end
end
