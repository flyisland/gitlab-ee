# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Report
          class CommitsPushed < Report::Base
            def self.header
              "Commits"
            end

            def query_count
              return [] unless valid_branch?

              emails = commits.map(&:author_email).uniq.compact
              users = User.preload(:emails).by_any_email(emails, confirmed: true) # rubocop:disable CodeReuse/ActiveRecord
              email_users = emails.index_with { |email| users.detect { |user| user.any_email?(email) } }

              result = commits.group_by do |commit|
                email_users[commit.author_email] || CommitAuthor.new(commit.author_name, commit.author_email)
              end
              result = result.transform_values(&:size).sort_by { |_key, value| -value }

              result.map.with_index do |(user, value), _index|
                key = user.is_a?(User) ? user.id : user
                [key, value]
              end
            end

            def query_summary
              return 0 unless valid_branch?

              commits.count
            end
          end
        end
      end
    end
  end
end
