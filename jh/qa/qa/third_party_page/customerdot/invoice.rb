# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class Invoice < Page::Base
        def choose_alipay
          Support::Waiter.wait_until(sleep_interval: 2) do
            has_element?('third-pay')
          end
          click_element('third-pay')
        end

        def choose_union_pay
          Support::Waiter.wait_until(sleep_interval: 2) do
            has_element?('union-pay')
          end
          click_element('union-pay')
        end

        def choose_china_pay
          Support::Waiter.wait_until(sleep_interval: 2) do
            has_element?('china-pay')
          end
          click_element('china-pay')
        end

        def choose_china_b2b_pay
          find('label.custom-control-label', text: /企业网银/).click
          QA::Runtime::Logger.info("Go to payment")
        end

        def continue_to_payment
          find('span.gl-button-text', text: /立即支付/).click
          QA::Runtime::Logger.info("Go to payment")
        end

        def page_shown?
          has_text?('立即支付')
        end
      end
    end
  end
end
