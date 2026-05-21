# frozen_string_literal: true

module Security
  class UnenforceablePolicyRulesNotificationWorker
    include ApplicationWorker
    include ::Security::SecurityOrchestrationPolicies::PolicySyncState::Callbacks

    idempotent!
    data_consistency :sticky
    feature_category :security_policy_management

    def perform(merge_request_id, params = {})
      merge_request = MergeRequest.find_by_id(merge_request_id)

      return unless merge_request

      project = merge_request.project
      return unless project.licensed_feature_available?(:security_orchestration_policies)

      if !merge_request_has_approval_policy_rules?(merge_request) && params['force_without_approval_rules'].blank?
        return finish_merge_request_worker_policy_sync(merge_request_id)
      end

      Security::UnenforceablePolicyRulesNotificationService.new(merge_request).execute

      finish_merge_request_worker_policy_sync(merge_request_id)
    end

    private

    def merge_request_has_approval_policy_rules?(merge_request)
      if Feature.enabled?(:deprecate_scan_result_policies, merge_request.project)
        merge_request.approval_rules.with_approval_policy_rule.any?
      else
        merge_request.approval_rules.with_scan_result_policy_read.any?
      end
    end
  end
end
