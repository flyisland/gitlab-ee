# frozen_string_literal: true

module Analytics
  module PerformanceAnalytics
    class ProjectLevel
      include ::Gitlab::Utils::StrongMemoize

      attr_reader :options, :project

      def initialize(project, options: {})
        @project = project
        @options = options.merge(project: project)
      end

      def summary_data
        Gitlab::Analytics::PerformanceAnalytics::ProjectSummary.new(project, options: options).data
      end
      strong_memoize_attr :summary_data

      def leaderboard_data
        Gitlab::Analytics::PerformanceAnalytics::ProjectLeaderboard.new(project, options: options).data
      end
      strong_memoize_attr :leaderboard_data

      def report
        Gitlab::Analytics::PerformanceAnalytics::ProjectReport.new(project, options: options)
      end
      strong_memoize_attr :report

      def report_summary
        report.summary
      end
      strong_memoize_attr :report_summary

      def report_data
        report.data
      end
      strong_memoize_attr :report_data

      def report_pagination
        report.pagination
      end
      strong_memoize_attr :report_pagination

      def report_csv
        report.csv
      end
      strong_memoize_attr :report_csv
    end
  end
end
