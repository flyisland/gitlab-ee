# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module ProjectHelper
        extend ActiveSupport::Concern
        include ::Gitlab::Utils::StrongMemoize
        include AvatarsHelper

        COMMITS_LIMIT = 6000

        CommitAuthor = Struct.new(:name, :email)

        def commits
          project.repository.commits(
            options[:branch_name],
            limit: COMMITS_LIMIT,
            before: options[:to],
            after: options[:from],
            skip_merges: true
          )
        end
        strong_memoize_attr :commits

        def valid_branch?
          project.repository.branch_exists?(options[:branch_name])
        end

        def time_filter_range
          options[:from]..(options[:to].end_of_day)
        end

        def user_data(user)
          {
            fullname: user.name,
            username: user.username,
            user_web_url: "/#{user.username}",
            avatar: user.avatar_url
          }
        end

        def commit_author_data(commit_author)
          {
            fullname: commit_author.name,
            username: commit_author.name,
            user_web_url: nil,
            avatar: default_avatar
          }
        end
      end
    end
  end
end
