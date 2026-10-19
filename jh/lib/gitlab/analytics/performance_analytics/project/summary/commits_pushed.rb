# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Summary
          class CommitsPushed < Summary::Base
            def data
              valid_branch? ? commits.count : 0
            end
          end
        end
      end
    end
  end
end
