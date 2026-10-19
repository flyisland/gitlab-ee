# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Report
          class MergeRequestsApproved < Report::BaseEvent
            def self.header
              "Approved MRs"
            end

            def event_target_action_scope
              Event.for_merge_request.for_action(:approved)
            end
          end
        end
      end
    end
  end
end
