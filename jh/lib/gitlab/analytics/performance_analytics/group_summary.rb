# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      class GroupSummary
        include ::Gitlab::Utils::StrongMemoize

        attr_reader :group, :options

        def initialize(group, options: {})
          @group = group
          @options = options
        end

        def data
          {
            issues_closed: issues_closed,
            commits_pushed: commits_pushed,
            merge_requests_merged: merge_requests_merged,
            commits_pushed_per_capita: commits_pushed_per_capita
          }
        end

        private

        def issues_closed
          Group::Summary::IssuesClosed.new(group, options: options).data
        end

        def commits_pushed
          Group::Summary::CommitsPushed.new(group, options: options).data
        end
        strong_memoize_attr :commits_pushed

        def merge_requests_merged
          Group::Summary::MergeRequestsMerged.new(group, options: options).data
        end

        def commits_pushed_per_capita
          Group::Summary::CommitsPushedPerCapita.new(group, options: options.merge(pushed_count: commits_pushed)).data
        end
      end
    end
  end
end
