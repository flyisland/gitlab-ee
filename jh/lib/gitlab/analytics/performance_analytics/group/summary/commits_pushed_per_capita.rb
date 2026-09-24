# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Summary
          class CommitsPushedPerCapita < Summary::Base
            def data
              users_count = base_push_event_payload_query.count("distinct events.author_id")

              pushed_count = options[:pushed_count] || Group::Summary::CommitsPushed.new(
                group, options: options
              ).data

              return 0 if users_count == 0 || pushed_count == 0

              (pushed_count * 1.0 / users_count).round(2)
            end
          end
        end
      end
    end
  end
end
