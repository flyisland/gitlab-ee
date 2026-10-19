# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Report
          class MergeRequestsClosed < Report::BaseEvent
            def self.header
              "Closed MRs"
            end

            def event_target_action_scope
              Event.for_merge_request.for_action(:closed)
            end
          end
        end
      end
    end
  end
end
