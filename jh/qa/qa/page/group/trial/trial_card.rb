# frozen_string_literal: true

module QA
  module Page
    module Group
      module Trial
        class TrialCard < ::QA::Page::Base
          view 'jh/app/views/groups/_group_activity_analytics.html.haml' do
            element 'upgrade-button'
            element 'explore-plans-button'
          end

          def has_group_trial_duration_card?
            has_text?("Group ultimate trial time")
          end

          def has_upgrade_button?
            has_element?("upgrade-button")
          end

          def has_explore_button?
            has_element?("explore-plans-button")
          end
        end
      end
    end
  end
end
