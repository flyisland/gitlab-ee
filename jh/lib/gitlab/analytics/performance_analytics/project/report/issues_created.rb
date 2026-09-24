# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Report
          class IssuesCreated < Report::BaseEvent
            def self.header
              "Created issues"
            end

            def event_target_action_scope
              Event.for_issue.for_action(:created)
            end
          end
        end
      end
    end
  end
end
