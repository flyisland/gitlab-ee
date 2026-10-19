# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class Subscription < ::QA::Page::Base
        def fill_seat_quantity(quantity)
          Support::Retrier.retry_until(max_attempts: 6, reload_page: true, sleep_interval: 5) do
            scroll_to_element("user-quantity")
            has_css?('input[data-testid="user-quantity"]', visible: true)
          end

          find('input[data-testid=user-quantity]').fill_in(with: quantity)
          # Press enter for price recalculation
          find('input[data-testid="user-quantity"]').send_keys(:enter)
          QA::Runtime::Logger.info("Filling #{quantity} in number of seats")
        end

        def fill_addon_quantity(quantity)
          Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 5) do
            has_css?('input[data-testid="quantity"]', visible: true)
          end

          find('input[data-testid="quantity"]').fill_in(with: quantity)
          # Press enter for price recalculation
          find('input[data-testid="quantity"]').send_keys(:enter)
          QA::Runtime::Logger.info("Filling #{quantity} in addon page")
        end

        def fill_credits_quantity(quantity)
          Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 5) do
            has_css?('input[data-testid="purchase-details-quantity-input"]', visible: true)
          end

          find('input[data-testid="purchase-details-quantity-input"]').fill_in(with: quantity)
          QA::Runtime::Logger.info("Filling #{quantity} in credits page")
        end

        def total_amount
          find('[data-testid="total"]').text.gsub(/[^\d.]/, '').to_f
        end

        def accept_terms_and_conditions
          terms_checkbox = find('#acceptTerms', visible: :all)
          execute_script('arguments[0].click()', terms_checkbox)
          QA::Runtime::Logger.info("Accepted terms and conditions")
        end

        def continue_purchase_credits_after_fill_quantity
          find('button[data-testid="responsive-button"]').click
        end

        def confirm_credits_purchase
          Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 2) do
            has_css?('button[data-testid="responsive-button"]:not([disabled])', visible: true)
          end

          find('button[data-testid="responsive-button"]').click
          QA::Runtime::Logger.info("Confirm purchase credits, go to payment")
        end

        def confirm_purchase
          Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 2) do
            has_css?('button[data-qa-value="confirm"]:not(.disabled)', visible: true)
          end

          Support::WaitForRequests.wait_for_requests(skip_spinner_check: false, spinner_wait: 3)

          find('button[data-qa-value="confirm"]').click
          QA::Runtime::Logger.info("Confirm purchase, go to payment")
        end

        def has_subscription_info_fill_complete?
          success = Support::Retrier.retry_on_exception(
            max_attempts: 5,
            sleep_interval: 2,
            message: 'Checking for payment methods page after subscription confirmation'
          ) do
            has_text?('Payment methods', wait: 5) || has_text?('支付方式', wait: 5)
          end

          QA::Runtime::Logger.info(
            "Subscription info has been #{success ? 'successfully committed' : 'not successfully committed'}"
          )
          success
        rescue Selenium::WebDriver::Error::WebDriverError => e
          QA::Runtime::Logger.error("Failed to verify payment page: #{e.class} - #{e.message}")
          QA::Runtime::Logger.error("Current URL: #{Capybara.current_url}")
          false
        end

        def wait_for_payment_page!
          return if has_subscription_info_fill_complete?

          raise "Failed to navigate to payment page. Current URL: #{Capybara.current_url}"
        end

        def seat_limit_content_valid?
          has_content?('Subscription exceeds the team plan seats limit') ||
            has_content?('您最多只能为团队版购买10个席位。要继续购买，请升级到更高版本。')
        end

        def wait_for_redirect_to_customers_portal
          Support::Waiter.wait_until(
            sleep_interval: 3,
            retry_on_exception: true,
            message: 'Waiting for redirect to Customers Portal'
          ) do
            has_text?('Customers Portal', wait: 1) || has_text?('极狐订单管理中心', wait: 1)
          end
        end

        def go_to_gitlab_credits_dashboard
          click_link('GitLab Credits dashboard')
        end

        def subscription_number
          find('.subscription-list [name^="A-SJH"]', wait: 30)[:name]
        end

        def verify_monthly_credits_details(expected_quantity)
          expand_product_details('GitLab Credits - Monthly Committed Pool')
          has_text?('GitLab Credits - Monthly Committed Pool', wait: 5) && has_text?(expected_quantity.to_s, wait: 5)
        end

        def verify_monthly_credits_dashboard(expected_quantity)
          has_text?('GitLab Credits - Monthly committed pool', wait: 10) &&
            has_css?(
              '[data-testid="total-credits"]',
              text: %r{\A/\s*#{Regexp.escape(expected_quantity.to_s)}\z},
              wait: 10
            )
        end

        def expand_product_details(product_title)
          product_section = find("[data-testid='product-details']", text: product_title)
          within(product_section) do
            click_button('Show details') if has_button?('Show details', wait: 1)
          end
        end

        def switch_language(language = 'en')
          find('#jh-i18n-btn', wait: 5).click
          find("a[href=\"/subscriptions?locale=#{language}\"]", wait: 5).click
          Support::WaitForRequests.wait_for_requests(skip_spinner_check: false, spinner_wait: 3)

          QA::Runtime::Logger.info("Switched language to #{language}")
        end
      end
    end
  end
end
