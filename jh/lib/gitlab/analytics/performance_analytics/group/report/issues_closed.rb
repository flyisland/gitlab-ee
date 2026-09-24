# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Report
          class IssuesClosed < Report::BaseEvent
            def self.header
              "Closed issues"
            end

            def event_target_action_scope
              Event.for_issue.for_action(:closed)
            end
          end
        end
      end
    end
  end
end
