# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Leaderboard
          class MergeRequestsMerged < Leaderboard::Base
            # rubocop: disable CodeReuse/ActiveRecord
            def query_result
              query =
                Event.where(target_type: "MergeRequest", action: :merged)
                    .where(events: { created_at: time_filter_range })
                    .joins(:project)
                    .merge(::Project.for_group_and_its_subgroups(group))

              query = query.where(projects: { id: options[:project_ids] }) if options[:project_ids].present?

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
