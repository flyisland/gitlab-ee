# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Leaderboard
          class MergeRequestsMerged < Leaderboard::Base
            # rubocop: disable CodeReuse/ActiveRecord
            def query_result
              query = Event.for_merge_request.for_action(:merged)
                          .created_at(time_filter_range).for_single_project(project)
              query_sql = query.group("author_id")
                              .select("author_id, count(*) as count")
                              .order("count desc")
                              .limit(LIMIT_COUNT).to_sql

              ApplicationRecord.connection.query(query_sql)
            end
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
