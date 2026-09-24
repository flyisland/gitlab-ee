# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module CustomerPortal
      class Home < ::QA::Page::Base
        def signed_in_to_portal(wait: Capybara.default_max_wait_time)
          customer_portal_origin? && has_css?('header button[aria-haspopup="menu"]', wait: wait)
        end

        def signed_in_as?(user)
          open_user_menu
          within('[role="menu"]') do
            has_text?("/#{user.username}")
          end
        end

        def open_access_control_users
          click_link('用户')
        end

        def open_finance
          click_link('收款单')
        end

        def open_subscriptions
          click_link('订阅管理')
        end

        def sign_out
          retry_until(message: 'Sign out from Customer Portal') do
            open_user_menu
            within('[role="menu"]') { click_button('退出') }
            CustomerPortal::SignIn.perform { |sign_in| sign_in.has_sign_in_button?(wait: 1) }
          end
        end

        private

        def open_user_menu
          return if has_css?('[role="menu"]', wait: 0)

          find('header button[aria-haspopup="menu"]').click
        end

        def customer_portal_origin?
          current_uri = URI.parse(page.current_url)
          portal_uri = URI.parse(Runtime::Env.customer_portal_url)

          current_origin = [current_uri.scheme, current_uri.host, current_uri.port]
          portal_origin = [portal_uri.scheme, portal_uri.host, portal_uri.port]

          current_origin == portal_origin
        end
      end
    end
  end
end
