# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Summary
          class CommitsPushed < Summary::Base
            def data
              base_push_event_payload_query.count
            end
          end
        end
      end
    end
  end
end
