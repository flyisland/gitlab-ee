# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class Chinapay < ::QA::Page::Base
        def payment_success
          Support::Waiter.wait_until(reload_page: page, retry_on_exception: true) do
            has_payment_success_button?
          end

          click_payment_success_button
          QA::Runtime::Logger.info("Payment success!")
        end

        private

        def has_payment_success_button?
          has_css?('a', text: /支付成功/, wait: 0)
        end

        def click_payment_success_button
          find('a', text: /支付成功/).click
        end
      end
    end
  end
end
