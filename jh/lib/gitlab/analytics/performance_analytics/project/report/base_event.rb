# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Report
          class BaseEvent < Base
            # rubocop: disable CodeReuse/ActiveRecord
            def base_event_query
              query = Event.created_at(time_filter_range).for_single_project(project)
              query.and(event_target_action_scope)
            end

            def query_count
              query = base_event_query.group("author_id").select("author_id, count(*) as count")
              ApplicationRecord.connection.query(query.to_sql)
            end
            # rubocop: enable CodeReuse/ActiveRecord

            def query_summary
              base_event_query.count
            end

            def event_target_action_scope
              raise NotImplementedError, "Expected #{self.class} to implement event_target_action_scope"
            end
          end
        end
      end
    end
  end
end
