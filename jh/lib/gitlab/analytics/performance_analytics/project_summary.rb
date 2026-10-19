# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      class ProjectSummary
        include ::Gitlab::Utils::StrongMemoize

        attr_reader :project, :options

        def initialize(project, options: {})
          @project = project
          @options = options
        end

        def data
          {
            issues_closed: issues_closed,
            commits_pushed: commits_pushed.data,
            merge_requests_merged: merge_requests_merged,
            commits_pushed_per_capita: commits_pushed_per_capita
          }
        end

        private

        def issues_closed
          Project::Summary::IssuesClosed.new(project, options: options).data
        end

        def commits_pushed
          Project::Summary::CommitsPushed.new(project, options: options)
        end
        strong_memoize_attr :commits_pushed

        def merge_requests_merged
          Project::Summary::MergeRequestsMerged.new(project, options: options).data
        end

        def commits_pushed_per_capita
          Project::Summary::CommitsPushedPerCapita.new(project,
            options: options.merge(commits: commits_pushed.commits)).data
        end
      end
    end
  end
end
