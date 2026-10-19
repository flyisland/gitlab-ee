# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Report
          class MergeRequestsMerged < Report::BaseEvent
            def self.header
              "Merged MRs"
            end

            def event_target_action_scope
              Event.for_merge_request.for_action(:merged)
            end
          end
        end
      end
    end
  end
end
