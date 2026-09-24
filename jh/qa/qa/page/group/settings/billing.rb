# frozen_string_literal: true

module QA
  module Page
    module Group
      module Settings
        class Billing < ::QA::Page::Base
          view 'jh/app/views/shared/billings/_billing_plans_layout.html.haml' do
            element 'billing-plan-header-content'
          end

          def go_to_free_trial
            find("span", text: "Try for free").click
          end

          def go_to_purchase_premium
            find("span", text: "Upgrade to Premium").click
          end

          def go_to_purchase_ultimate
            find("span", text: "Upgrade to Ultimate").click
          end

          def go_to_purchase_team
            find("span", text: "Upgrade to Team").click
          end

          def go_to_upgrade_premium_from_trial
            find("span", text: "Upgrade to Premium").click
          end

          def go_to_upgrade_ultimate_from_trial
            find("span", text: "Upgrade to Ultimate").click
          end

          def go_to_upgrade_team
            find("span", text: "Upgrade to Team").click
          end

          def go_to_upgrade_premium
            find("[data-testid='upgrade-to-premium']").click
          end

          def go_to_upgrade_ultimate
            find("[data-testid='upgrade-to-ultimate']").click
          end

          def wait_for_billing_page_loaded
            wait_until(max_duration: 10, sleep_interval: 2) do
              has_element?('billing-plan-header-content')
            end
          end

          def wait_for_free_trial_billing_page_loaded
            wait_until(max_duration: 10, sleep_interval: 2) do
              has_element?('free-trial-plan-billing-content')
            end
          end

          def purchase_credits_in_billing
            click_element('dap-monthly-credit-card-cta-button')
          end

          def purchased_credits
            find_element('subscription-credits').text.gsub(/[^\d.]/, '').to_i
          end
        end
      end
    end
  end
end
