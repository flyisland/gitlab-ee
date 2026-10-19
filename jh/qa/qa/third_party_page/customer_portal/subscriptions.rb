# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module CustomerPortal
      class Subscriptions < ::QA::Page::Base
        QUOTA_LABELS = {
          prepaid: '预购额度',
          postpaid: '按需额度'
        }.freeze

        def open_subscription(subscription_number)
          retry_until(max_attempts: 6, reload: true, sleep_interval: 5, message: 'Find the new subscription') do
            search = find('input[aria-label="搜索"]', wait: 30)
            search.set(subscription_number) unless search.value == subscription_number
            has_css?('tr[data-subscription-row="true"]', text: subscription_number, wait: 5)
          end

          find('tr[data-subscription-row="true"]', text: subscription_number).click
        end

        def grant_credits(type:, amount:)
          quota_label = QUOTA_LABELS.fetch(type)

          click_button('发放额度')
          within('[role="menu"]') { click_button(quota_label) }

          within('[role="dialog"]', text: "增加#{quota_label}") do
            find('input[aria-label="Credits"]', wait: 30).set(amount)
            click_button('确认发放')
          end

          has_no_css?('[role="dialog"]', text: "增加#{quota_label}")
        end

        def has_granted_credits?(type:, amount:, monthly_amount:)
          quota_label = QUOTA_LABELS.fetch(type)

          has_text?('月度额度') &&
            has_text?("合计 #{monthly_amount} Credits · 当月剩余 #{monthly_amount} Credits") &&
            has_text?("#{quota_label} #{amount} Credits · 剩余 #{amount} Credits")
        end
      end
    end
  end
end
