# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class Signin < ::QA::Page::Base
        def login(user: nil)
          find('button[type=submit]').click
          QA::Runtime::Logger.info("Click login button")

          wait_if_retry_later

          fill_element 'username-field', user&.username || Runtime::User::Store.test_user_username
          fill_element 'password-field', user&.password || Runtime::User::Store.test_user_password

          click_element 'sign-in-button'

          Support::WaitForRequests.wait_for_requests

          wait_for_gitlab_to_respond
        end

        def oauth_login
          if has_css?('button[data-testid=sign-in-with-gitlab-button]', visible: true)
            find('button[data-testid=sign-in-with-gitlab-button]').click
          else
            QA::Runtime::Logger.info("Sign in button not found, skipping login.")
          end
        end
      end
    end
  end
end
