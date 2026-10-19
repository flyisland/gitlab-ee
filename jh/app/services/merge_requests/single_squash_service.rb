# frozen_string_literal: true

module MergeRequests
  class SingleSquashService < ::MergeRequests::SquashService
    extend ::Gitlab::Utils::Override

    override :execute
    def execute
      squash! || error(
        s_('MergeRequests|Squashing failed: Squash the commits locally, resolve any conflicts, then push the branch.'))
    end

    private

    override :squash!
    def squash!
      squash_sha = repository.squash_to_target_branch_head(current_user, merge_request, message)

      success(squash_sha: squash_sha)
    rescue StandardError => e
      log_error(exception: e, message: 'Failed to squash merge request')

      false
    end
  end
end
