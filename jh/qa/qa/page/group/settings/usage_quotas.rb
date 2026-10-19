# frozen_string_literal: true

module QA
  module Page
    module Group
      module Settings
        class UsageQuotas < ::QA::Page::Base
          view 'ee/app/assets/javascripts/usage_quotas/storage/namespace/components/storage_usage_statistics.vue' do
            element 'purchase-more-storage'
          end

          view 'ee/app/assets/javascripts/usage_quotas/pipelines/namespace/components/app.vue' do
            element 'buy-compute-minutes'
          end

          view 'ee/app/assets/javascripts/usage_quotas/pipelines/namespace/components/cards' \
            '/additional_units_usage_summary.vue' do
            element 'additional-compute-minutes'
          end

          view 'ee/app/assets/javascripts/usage_quotas/pipelines/namespace/components/cards/' \
            'monthly_units_usage_summary.vue' do
            element 'plan-compute-minutes'
          end

          view 'ee/app/assets/javascripts/usage_quotas/pipelines/namespace/tab_metadata.js' do
            element 'pipelines-tab'
          end

          view 'app/assets/javascripts/usage_quotas/storage/utils.js' do
            element 'storage-tab'
          end

          def purchased_ci_minutes
            wait_until(max_duration: 30, sleep_interval: 1, message: 'Wait for additional compute minutes element') do
              has_element?('additional-compute-minutes', wait: 0)
            end

            find_element('additional-compute-minutes').text.split('/').last.gsub(/[^\d.]/, '').to_i
          end

          def plan_ci_minutes
            wait_until(max_duration: 30, sleep_interval: 1, message: 'Wait for plan compute minutes element') do
              has_element?('plan-compute-minutes', wait: 0)
            end

            find_element('plan-compute-minutes').text.split('/').last.gsub(/[^\d.]/, '').to_i
          end

          def switch_to_ci_minutes
            click_element('pipelines-tab')
          end

          def buy_ci_minutes
            click_element('buy-compute-minutes')
          end

          def switch_to_storage
            click_element('storage-tab')
          end

          def buy_storage
            click_element('purchase-more-storage')
          end

          def has_purchase_more_button?
            has_css?('span.gl-button-text', text: /Purchase more storage/)
          end

          def buy_more_storage
            find('span.gl-button-text', text: /Purchase more storage/).click
          end

          def purchased_storage
            wait_until(max_duration: 30, sleep_interval: 1, message: 'Wait for storage element') do
              has_css?('span[data-testid=denominator-total]', wait: 0) || has_element?('storage-purchased', wait: 0)
            end

            if has_css?('span[data-testid=denominator-total]')
              find('span[data-testid=denominator-total]').text.split('/').last.match(/\d+\.\d+/)[0].to_f
            else
              find_element("storage-purchased").text.split('/').last.match(/\d+\.\d+/)[0].to_f
            end
          end

          def has_group_usage_message_content?
            has_element?('group-usage-message-content')
          end

          def switch_window
            browser = page.driver.browser
            browser.switch_to.window(browser.window_handles.last) if browser.window_handles.length == 2
          end

          def close_window
            browser = page.driver.browser
            return unless browser.window_handles.length == 2

            browser.close
            browser.switch_to.window(browser.window_handles.first)
            refresh
          end
        end
      end
    end
  end
end
