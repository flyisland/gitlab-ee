# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Leaderboard
          class CommitsPushed < Leaderboard::Base
            def data
              return [] unless valid_branch?

              emails = commits.map(&:author_email).uniq.compact
              users = User.preload(:emails).by_any_email(emails, confirmed: true) # rubocop:disable CodeReuse/ActiveRecord
              email_users = emails.index_with { |email| users.detect { |user| user.any_email?(email) } }

              result = commits.group_by do |commit|
                email_users[commit.author_email] || CommitAuthor.new(commit.author_name, commit.author_email)
              end
              result = result.transform_values(&:size).sort_by { |_key, value| -value }.first(LIMIT_COUNT)

              result.map.with_index do |(user, value), index|
                {
                  user: user.is_a?(User) ? user_data(user) : commit_author_data(user),
                  rank: index + 1,
                  value: value.to_i
                }
              end
            end
          end
        end
      end
    end
  end
end
