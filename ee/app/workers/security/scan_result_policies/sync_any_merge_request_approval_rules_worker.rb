# frozen_string_literal: true

module Security
  module ScanResultPolicies
    class SyncAnyMergeRequestApprovalRulesWorker
      include ApplicationWorker
      include ::Security::SecurityOrchestrationPolicies::PolicySyncState::Callbacks

      idempotent!
      deduplicate :until_executed, if_deduplicated: :reschedule_once
      data_consistency :always
      sidekiq_options retry: true
      urgency :low
      concurrency_limit -> { 200 }

      feature_category :security_policy_management

      def perform(merge_request_id)
        merge_request = MergeRequest.find_by_id(merge_request_id)

        return finish_merge_request_worker_policy_sync(merge_request_id) unless merge_request

        Security::ScanResultPolicies::SyncAnyMergeRequestRulesService.new(merge_request).execute

        finish_merge_request_worker_policy_sync(merge_request_id)
      end
    end
  end
end
