# frozen_string_literal: true

module MergeRequests
  class AutoAssignReviewersWorker
    include ApplicationWorker

    idempotent!
    data_consistency :sticky
    urgency :low
    feature_category :code_review_workflow
    defer_on_database_health_signal :gitlab_main

    def perform(merge_request_id)
      merge_request = MergeRequest.find_by_id(merge_request_id)
      return unless merge_request
      return unless merge_request.reviewer_auto_assignment_enabled?

      automation_bot = ::Users::Internal.in_organization(merge_request.project.organization_id).automation_bot

      ReviewerAssignment::AssignService.new(
        merge_request: merge_request,
        current_user: automation_bot
      ).execute
    end
  end
end
