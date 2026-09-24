# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Summary
          class IssuesClosed < Summary::Base
            # rubocop: disable CodeReuse/ActiveRecord
            def data
              query = Event.for_issue.for_action(:closed)
                          .where(events: { created_at: time_filter_range })
                          .joins(:project)
                          .merge(::Project.for_group_and_its_subgroups(group))

              query = query.where(projects: { id: options[:project_ids] }) if options[:project_ids].present?
              query.count
            end
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
