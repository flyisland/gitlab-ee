# frozen_string_literal: true

module EE
  module MergeRequests
    module CreatePipelineWorker
      extend ::Gitlab::Utils::Override

      override :after_perform
      def after_perform(merge_request)
        # When async pipeline creation is enabled, `schedule_policy_synchronization`
        # skips enqueuing `UnenforceablePolicyRulesNotificationWorker`.
        # This hook enqueues the worker once pipeline creation finishes and no
        # pipeline was produced.
        return if merge_request.diff_head_pipeline

        return unless merge_request.project.licensed_feature_available?(:security_orchestration_policies)

        ::Security::UnenforceablePolicyRulesNotificationWorker.perform_async(merge_request.id)
      end
    end
  end
end
