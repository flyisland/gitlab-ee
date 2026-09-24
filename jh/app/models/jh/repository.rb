# frozen_string_literal: true

module JH
  module Repository
    def squash_to_target_branch_head(user, merge_request, message)
      raw.squash(
        user,
        start_sha: merge_request.target_branch_head.try(:sha),
        end_sha: merge_request.diff_head_sha,
        author: merge_request.author,
        message: message
      )
    end
  end
end
