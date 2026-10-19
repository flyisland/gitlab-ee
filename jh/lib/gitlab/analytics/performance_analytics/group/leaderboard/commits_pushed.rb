# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Leaderboard
          class CommitsPushed < Leaderboard::Base
            # rubocop: disable CodeReuse/ActiveRecord
            def query_result
              query = base_push_event_payload_query

              query_sql = query.group("events.author_id")
                              .select("events.author_id, count(*) as count")
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
