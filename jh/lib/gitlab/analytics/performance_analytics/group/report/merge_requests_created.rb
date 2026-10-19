# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Report
          class MergeRequestsCreated < Report::BaseEvent
            def self.header
              "Created MRs"
            end

            def event_target_action_scope
              Event.for_merge_request.for_action(:created)
            end
          end
        end
      end
    end
  end
end
