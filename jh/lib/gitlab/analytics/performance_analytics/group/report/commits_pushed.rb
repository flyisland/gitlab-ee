# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Report
          class CommitsPushed < Report::BaseEvent
            def self.header
              "Pushes"
            end

            # rubocop: disable CodeReuse/ActiveRecord
            def query_count
              query = base_push_event_payload_query

              query_sql = query.group("events.author_id").select("events.author_id, count(*) as count").to_sql

              ApplicationRecord.connection.query(query_sql)
            end
            # rubocop: enable CodeReuse/ActiveRecord

            def query_summary
              base_push_event_payload_query.count
            end
          end
        end
      end
    end
  end
end
