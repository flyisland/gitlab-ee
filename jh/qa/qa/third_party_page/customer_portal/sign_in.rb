# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module CustomerPortal
      class SignIn < ::QA::Page::Base
        def sign_in_with_jihulab
          click_button('使用 jihulab.com 登录')
        end

        def has_sign_in_button?(wait: Capybara.default_max_wait_time)
          has_button?('使用 jihulab.com 登录', wait: wait)
        end
      end
    end
  end
end
