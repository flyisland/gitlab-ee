# frozen_string_literal: true

module QA
  module Page
    module Group
      module Settings
        class GitlabCredits < ::QA::Page::Base
          include Page::SubMenus::Common

          view 'ee/app/assets/javascripts/usage_quotas/wallet_agnostic_credits_dashboard/index/components/' \
            'usage_cards.vue' do
            element 'total-usage-card'
          end

          def go_to_gitlab_credits
            open_submenu('Settings', 'GitLab Credits')
          end

          def wait_for_total_usage(max_duration: 120)
            total_usage = nil

            wait_until(
              max_duration: max_duration,
              sleep_interval: 5,
              message: 'Wait for GitLab Credits usage to update'
            ) do
              next false unless has_element?('total-usage-card', wait: 5)

              total_usage = find_element('total-usage-card').find('.gl-card-body .gl-font-bold').text.delete(',').to_f
              yield(total_usage)
            end

            total_usage
          end
        end
      end
    end
  end
end
