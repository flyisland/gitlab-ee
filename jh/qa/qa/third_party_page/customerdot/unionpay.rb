# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class Unionpay < ::QA::Page::Base
        def fill_bank_account
          Support::Waiter.wait_until(retry_on_exception: true, reload_page: page, sleep_interval: 2) do
            find('#cardNumber').fill_in(with: ::QA::Runtime::Env.bank_account)
          end
          QA::Runtime::Logger.info("Card number is entered")
        end

        def go_to_phone_verification
          Support::Retrier.retry_until(max_attempts: 6, sleep_interval: 2) do
            next true if has_css?('#realName', visible: true, wait: 0)

            find('#btnNext').click
            has_css?('#realName', visible: true)
          end
          QA::Runtime::Logger.info("Click next to go to phone verification")
        end

        def fill_payment_user_name
          Support::Waiter.wait_until(retry_on_exception: true, reload_page: page, sleep_interval: 2) do
            find('#realName').fill_in(with: ::QA::Runtime::Env.payment_user_name)
          end
          QA::Runtime::Logger.info("Payment user name is entered")
        end

        def fill_credential_card_num
          Support::Waiter.wait_until(retry_on_exception: true, reload_page: page, sleep_interval: 2) do
            find('#credentialNo').fill_in(with: ::QA::Runtime::Env.credential_card_num)
          end
          QA::Runtime::Logger.info("Credential card num is entered")
        end

        def sent_phone_sms_code
          Support::Waiter.wait_until do
            find('#btnGetCode').click
          end
          QA::Runtime::Logger.info("Click to get phone sms code")
        end

        def fill_phone_sms_code
          Support::Waiter.wait_until(retry_on_exception: true, reload_page: page, sleep_interval: 2) do
            find('#smsCode').fill_in(with: ::QA::Runtime::Env.phone_sms_code)
          end
          QA::Runtime::Logger.info("Phone code is entered")
        end

        def confirm_payment
          Support::Waiter.wait_until do
            find('#btnCardPay').click
          end
          QA::Runtime::Logger.info("Click to confirm payment")
        end

        def has_payment_successful?
          success = has_text?('Payment Succeeded') || has_text?('您已成功支付')
          QA::Runtime::Logger.info("Payment has #{success ? 'been successful' : 'not been successful'}")
          success
        end

        def back_to_customer_dot
          Support::Waiter.wait_until do
            find('#btnBack').click
          end
          QA::Runtime::Logger.info("Click return to merchant")
        end

        def check_agreement
          Support::Waiter.wait_until do
            find('#isCheckAgreement').click
          end
          QA::Runtime::Logger.info("Check agreement")
        end

        def complete_phone_verification
          Support::Waiter.wait_until(reload_page: page, sleep_interval: 5) do
            fill_payment_user_name
            fill_credential_card_num
            sent_phone_sms_code
            fill_phone_sms_code
            check_agreement
            confirm_payment
            has_payment_successful?
          end
        end
      end
    end
  end
end
