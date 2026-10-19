# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module CustomerPortal
      class MySubscriptions < ::QA::Page::Base
        def open_subscription(subscription_number)
          retry_until(
            max_attempts: 6,
            reload: true,
            sleep_interval: 5,
            message: 'Find the customer subscription'
          ) do
            has_css?('tbody tr', text: subscription_number, wait: 5)
          end

          find('tbody tr', text: subscription_number).click
          find('h1', text: subscription_number)
          find_button('购买预购额度')
        end

        def has_no_prepaid_credits?
          within('[aria-labelledby="subscription-otc-grants-title"]') do
            has_text?('当前订阅暂无额度发放', wait: 30)
          end
        end

        def has_prepaid_credits?(quantity)
          within('[aria-labelledby="subscription-otc-grants-title"]') do
            has_css?(
              'p',
              text: /\A预购额度\s+#{quantity} Credits\s+·\s+剩余\s+#{quantity} Credits\z/,
              wait: 30
            ) &&
              has_css?('tr[data-subscription-otc-grant]', text: '预购')
          end
        end

        def has_monthly_credits?(quantity)
          within('[data-purchased-product-group]', text: '月度额度') do
            has_text?("#{quantity} Credits · 当月剩余 #{quantity} Credits", wait: 30)
          end
        end

        def select_prepaid_credits(quantity)
          click_button('购买预购额度')

          within('[aria-labelledby="prepaid-topup-title"]') do
            click_button("#{quantity} Credits", exact: true)
            check('acceptTerms')
            find('button[type="submit"]:not([disabled])').click
          end

          find('[aria-labelledby="prepaid-payment-modal-title"]')
        end

        def open_payment_window
          page.window_opened_by do
            within('[aria-labelledby="prepaid-payment-modal-title"]') do
              click_button('个人网银')
            end
          end
        end

        def wait_for_payment_success
          retry_until(
            max_attempts: 12,
            sleep_interval: 5,
            message: 'Wait for prepaid payment and credits delivery'
          ) do
            next true if payment_successful?

            if has_css?('[data-testid="prepaid-payment-overlay"]', wait: 1)
              within('[data-testid="prepaid-payment-overlay"]') do
                click_button('已完成付款')
              end
            end

            payment_successful?
          end
        end

        def finish_payment
          assert_no_selector('[data-testid="prepaid-payment-overlay"]')

          within('[aria-labelledby="prepaid-payment-modal-title"]') do
            click_button('完成')
          end

          assert_no_selector('[aria-labelledby="prepaid-payment-modal-title"]')
          find_button('购买预购额度')
        end

        private

        def payment_successful?
          within('[aria-labelledby="prepaid-payment-modal-title"]') do
            has_text?('已付款', wait: 5) &&
              has_text?('预购额度已到账，可在 Credits 额度中查看。', wait: 5)
          end
        end
      end
    end
  end
end
