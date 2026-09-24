# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      class GroupLeaderboard
        attr_reader :group, :leaderboard_type, :options

        LEADERBOARD_TYPES = %w[
          commits_pushed
          issues_closed
          merge_requests_merged
        ].freeze

        def initialize(group, options: {})
          @group = group
          @options = options
          @leaderboard_type = options[:leaderboard_type] || "commits_pushed"
        end

        def data
          return [] unless LEADERBOARD_TYPES.include?(leaderboard_type.to_s)

          Group::Leaderboard.const_get(leaderboard_type.to_s.classify, false).new(group, options: options).data
        end
      end
    end
  end
end
