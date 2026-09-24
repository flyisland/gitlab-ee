# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      class ProjectLeaderboard
        attr_reader :project, :leaderboard_type, :options

        LEADERBOARD_TYPES = %w[
          commits_pushed
          issues_closed
          merge_requests_merged
        ].freeze

        def initialize(project, options: {})
          @project = project
          @options = options
          @leaderboard_type = options[:leaderboard_type] || "commits_pushed"
        end

        def data
          return [] unless LEADERBOARD_TYPES.include?(leaderboard_type.to_s)

          Project::Leaderboard.const_get(leaderboard_type.to_s.classify, false).new(project, options: options).data
        end
      end
    end
  end
end
