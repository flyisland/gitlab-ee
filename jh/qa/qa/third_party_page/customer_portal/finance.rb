# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module CustomerPortal
      class Finance < ::QA::Page::Base
        def statements_visible?(wait: Capybara.default_max_wait_time)
          has_css?('[data-finance-page="true"]', wait: wait) &&
            has_button?('待收款', wait: wait) &&
            has_button?('未出账', wait: 0) &&
            has_button?('已收款', wait: 0)
        end
      end
    end
  end
end
