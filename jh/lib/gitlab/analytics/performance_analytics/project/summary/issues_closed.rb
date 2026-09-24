# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Summary
          class IssuesClosed < Summary::Base
            def data
              Event.for_issue.for_action(:closed).created_at(time_filter_range).for_single_project(project).count
            end
          end
        end
      end
    end
  end
end
