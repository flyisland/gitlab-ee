# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class Landingpage < QA::Page::Base
        def switch_language
          find('#jh-i18n-btn').click
          click_link('English')
          QA::Runtime::Logger.info("Switching language to english")
        end

        def go_to_profile
          retry_until(reload: true, sleep_interval: 2, max_attempts: 3, message: 'Find profile settings') do
            switch_language

            within_element('profile') do
              click_element('base-dropdown-toggle')
            end

            QA::Runtime::Logger.info("Click my profile")
            has_text?('Profile settings')
          end

          click_link('Profile settings')
          QA::Runtime::Logger.info("Go to account details")
        end

        def sign_out
          within_element('profile') do
            click_element('base-dropdown-toggle')
          end

          QA::Runtime::Logger.info("Click my profile")

          has_text?('Sign out') ? click_link('Sign out') : click_link('退出')
          QA::Runtime::Logger.info("Sign out from customerdot")
        end
      end
    end
  end
end
