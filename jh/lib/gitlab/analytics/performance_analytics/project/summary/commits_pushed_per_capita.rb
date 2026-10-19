# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Summary
          class CommitsPushedPerCapita < Summary::Base
            def data
              return 0 unless valid_branch?

              all_commits = options[:commits] || commits
              commits_count = all_commits.count
              users_count = all_commits.map(&:author_email).uniq.count

              return 0 if commits_count == 0 || users_count == 0

              (commits_count * 1.0 / users_count).round(2)
            end
          end
        end
      end
    end
  end
end
