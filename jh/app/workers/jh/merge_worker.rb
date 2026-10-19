# frozen_string_literal: true

module JH
  module MergeWorker
    extend ::Gitlab::Utils::Override

    override :perform
    def perform(merge_request_id, current_user_id, params)
      super

      ::MergeRequests::MonorepoService.try_cancel_lease_if_possible!(merge_request_id)
    end
  end
end
