# frozen_string_literal: true

module QA
  module Flow
    module JhPurchase
      extend self

      def page
        Capybara.current_session
      end

      def purchase_subscription(plan, skip_payment: false)
        select_plan_action(plan, :purchase)

        oauth_login_customerdot
        complete_subscription_process(skip_payment)
      end

      def upgrade_subscription(plan, from_trial: false, skip_payment: false)
        if from_trial
          select_plan_action_from_trial(plan)
        else
          select_plan_action(plan, :upgrade)
        end

        oauth_login_customerdot
        complete_subscription_process(skip_payment)
      end

      def navigate_to_billing_page(group, plan_exists: true)
        Support::Retrier.retry_on_exception(
          max_attempts: 3,
          sleep_interval: 2,
          message: "Failed to navigate to billing page"
        ) do
          group.visit!
          ::QA::Page::Group::Menu.perform(&:go_to_billing)

          ::QA::Page::Group::Settings::Billing.perform do |billing|
            if plan_exists
              billing.wait_for_billing_page_loaded
            else
              billing.wait_for_free_trial_billing_page_loaded
            end
          end
        end
      end

      def select_plan_action(plan, action_type)
        ::QA::Page::Group::Settings::Billing.perform do |billing|
          case action_type
          when :purchase
            select_purchase_plan(billing, plan)
          when :upgrade
            select_upgrade_plan(billing, plan)
          else
            raise ArgumentError, "Unsupported action type: #{action_type}"
          end
        end
      end

      def select_plan_action_from_trial(plan)
        ::QA::Page::Group::Settings::Billing.perform do |billing|
          case plan
          when 'premium'
            billing.go_to_upgrade_premium_from_trial
          when 'ultimate'
            billing.go_to_upgrade_ultimate_from_trial
          else
            raise ArgumentError, "Unsupported upgrade plan from trial: #{plan}"
          end
        end
      end

      def select_purchase_plan(billing, plan)
        case plan
        when 'premium' then billing.go_to_purchase_premium
        when 'ultimate' then billing.go_to_purchase_ultimate
        when 'team' then billing.go_to_purchase_team
        else
          raise ArgumentError, "Unsupported purchase plan: #{plan}"
        end
      end

      def select_upgrade_plan(billing, plan)
        case plan
        when 'premium' then billing.go_to_upgrade_premium
        when 'ultimate' then billing.go_to_upgrade_ultimate
        when 'team' then billing.go_to_upgrade_team
        else
          raise ArgumentError, "Unsupported upgrade plan: #{plan}"
        end
      end

      def complete_subscription_process(skip_payment)
        complete_subscription_info
        choose_payment
        complete_payment unless skip_payment
      end

      def purchase_ci_minutes(quantity, skip_payment: false)
        ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
          usage_quota.switch_to_ci_minutes
          usage_quota.buy_ci_minutes
        end

        oauth_login_customerdot
        complete_addon_quantity(quantity)
        choose_payment
        complete_payment unless skip_payment
      end

      def navigate_to_usage_quotas(group)
        Support::Retrier.retry_on_exception(
          max_attempts: 3,
          sleep_interval: 1,
          message: "Failed to navigate to usage quotas page for group: #{group.path}"
        ) do
          group.visit!
          ::QA::Page::Group::Menu.perform(&:go_to_usage_quotas)

          ::QA::Page::Group::Settings::UsageQuotas.perform(&:has_group_usage_message_content?)
        end
      end

      def purchase_storage(quantity, skip_payment: false)
        ::QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
          usage_quota.switch_to_storage

          if usage_quota.has_purchase_more_button?
            usage_quota.buy_more_storage
          else
            usage_quota.buy_storage
          end

          usage_quota.switch_window
        end

        oauth_login_customerdot
        complete_addon_quantity(quantity)
        choose_payment
        complete_payment unless skip_payment

        ::QA::Page::Group::Settings::UsageQuotas.perform(&:close_window)
      end

      def purchase_credits(group, quantity, skip_payment: false, source: :duo, &verify_purchase_details)
        case source
        when :billing
          ::QA::Page::Group::Settings::Billing.perform(&:purchase_credits_in_billing)
        when :duo
          ::QA::Page::Group::Settings::GitlabDuo.perform(&:purchase_credits_in_duo_menu)
        else
          raise ArgumentError, "Unsupported source: #{source}. Expected :billing or :duo"
        end

        ::QA::Page::Group::Settings::UsageQuotas.perform(&:switch_window)

        oauth_login_customerdot
        complete_credits_quantity(quantity, &verify_purchase_details)
        choose_payment
        complete_payment unless skip_payment

        QA::Runtime::Logger.info("Credits purchase completed for group: #{group.path}")
      end

      def oauth_login_customerdot
        ::QA::ThirdPartyPage::Customerdot::Signin.perform(&:oauth_login)
        Support::WaitForRequests.wait_for_requests(skip_spinner_check: false, spinner_wait: 3)

        QA::Runtime::Logger.info("Oauth login to customerdot successful")
      end

      def choose_payment
        payment = ::QA::Runtime::Env.fulfillment_payment

        ::QA::ThirdPartyPage::Customerdot::Invoice.perform do |invoice|
          case payment
          when 'unionpay'
            invoice.choose_union_pay
          when 'alipay'
            invoice.choose_alipay
          when 'chinapay'
            invoice.choose_china_pay
            invoice.choose_china_b2b_pay
          end
          invoice.continue_to_payment
        end
      end

      def complete_payment
        payment = ::QA::Runtime::Env.fulfillment_payment

        case payment
        when 'unionpay'
          ::QA::ThirdPartyPage::Customerdot::Unionpay.perform do |unionpay|
            unionpay.fill_bank_account
            unionpay.go_to_phone_verification
            unionpay.complete_phone_verification
            unionpay.back_to_customer_dot
          end
        when 'chinapay'
          ::QA::ThirdPartyPage::Customerdot::Chinapay.perform(&:payment_success)
        end
      end

      def fill_seat_quantity(quantity)
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
          subscription.fill_seat_quantity(quantity)
        end
      end

      def complete_credits_quantity(quantity)
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
          subscription.fill_credits_quantity(quantity)
        end

        complete_fill_credits_quantity
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform { |subscription| yield(subscription) } if block_given?
        confirm_purchase_credits
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform(&:wait_for_payment_page!)
      end

      def complete_subscription_info
        confirm_purchase_subscription
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform(&:wait_for_payment_page!)
      end

      def complete_addon_quantity(quantity)
        change_addon_quantity(quantity)
        confirm_purchase_subscription
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform(&:wait_for_payment_page!)
      end

      def change_addon_quantity(quantity)
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
          subscription.fill_addon_quantity(quantity)
        end
      end

      def complete_fill_credits_quantity
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform(&:continue_purchase_credits_after_fill_quantity)
      end

      def confirm_purchase_subscription
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
          subscription.accept_terms_and_conditions
          subscription.confirm_purchase
        end
      end

      def confirm_purchase_credits
        ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
          subscription.accept_terms_and_conditions
          subscription.confirm_credits_purchase
        end
      end

      def verify_purchase_successful(group, plan_name)
        Page::Group::Settings::Billing.perform do |billing|
          expected_text = "#{group.path} is currently using the #{plan_name} Plan"
          billing.has_content?(expected_text)
        end
      end
    end
  end
end
