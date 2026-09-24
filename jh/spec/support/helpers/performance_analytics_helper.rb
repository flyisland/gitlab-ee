# frozen_string_literal: true

module JH
  module PerformanceAnalyticsHelper
    def create_commit(message, project, user, branch_name, count: 1, commit_time: nil, skip_push_handler: false)
      repository = project.repository
      oldrev = repository.commit(branch_name)&.sha || ::Gitlab::Git::SHA1_BLANK_SHA
      commit_shas = []

      travel_to(commit_time || Time.now) do
        commit_shas = Array.new(count) do |_index|
          commit_sha = repository.create_file(user, generate(:branch), "content",
            message: message, branch_name: branch_name)
          repository.commit(commit_sha)

          commit_sha
        end
      end

      return if skip_push_handler

      ::Git::BranchPushService.new(
        project,
        user,
        change: {
          oldrev: oldrev,
          newrev: commit_shas.last,
          ref: 'refs/heads/master'
        }
      ).execute
    end
  end
end
