# frozen_string_literal: true

module QA
  module Page
    module Registration
      class SignUp < Page::Base
        view 'app/views/devise/registrations/_signup_box_form.html.haml' do
          element 'new-user-email-field'
        end

        view 'jh/app/views/devise/shared/_signup_box.html.haml' do
          element 'new-user-register-button'
        end

        view 'app/views/devise/registrations/_password_input.html.haml' do
          element 'new-user-password-field'
        end

        view 'app/helpers/registrations_helper.rb' do
          element 'new-user-username-field'
        end

        def register_user(user)
          raise ArgumentError, 'User must be of type Resource::User' unless user.is_a? Resource::User

          fill_element 'new-user-first-name-field', user.first_name
          fill_element 'new-user-last-name-field', user.last_name
          fill_element 'new-user-username-field', user.username
          fill_element 'new-user-email-field', user.email
          fill_element 'new-user-password-field', user.password

          Support::Waiter.wait_until(sleep_interval: 0.5) do
            username_available? && has_element?('new-user-register-button', disabled: false, wait: 0)
          end

          click_element 'new-user-register-button'
        end

        private

        def username_available?
          page.has_content?("Username is available.", wait: 0) || page.has_content?("用户名可用。", wait: 0)
        end
      end
    end
  end
end
