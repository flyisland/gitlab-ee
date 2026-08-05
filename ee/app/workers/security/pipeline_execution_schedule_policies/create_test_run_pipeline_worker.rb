# frozen_string_literal: true

module Security
  module PipelineExecutionSchedulePolicies
    class CreateTestRunPipelineWorker
      include ApplicationWorker

      feature_category :security_policy_management
      # Idempotent: the pending? guard ensures duplicate runs are no-ops.
      # Only test runs in pending state are processed; all other states skip.
      idempotent!
      deduplicate :until_executed
      urgency :low
      data_consistency :delayed
      defer_on_database_health_signal :gitlab_main, [:scheduled_pipeline_execution_policy_test_runs]
      sidekiq_options retry: 3

      def perform(test_run_id)
        test_run = ::Security::ScheduledPipelineExecutionPolicyTestRun.find_by_id(test_run_id)
        return unless test_run&.pending?

        execute_pipeline(test_run)
      end

      private

      def execute_pipeline(test_run)
        result = ::Security::PipelineExecutionPolicies::CreateScheduledPipelineService.new(
          project: test_run.project,
          ci_content: test_run.security_policy.content['content'],
          policy: test_run.security_policy
        ).execute

        if result.success?
          pipeline = result.payload
          test_run.update!(pipeline: pipeline, state: :running)
        else
          test_run.update!(error_message: result.message, state: :failed)
        end

        # Notify frontend of state change (pending -> running or pending -> failed)
        # Only triggered after successful state transition, not on early returns
        ::GraphqlTriggers.security_policy_schedule_test_run_updated(test_run)
      rescue StandardError => e
        test_run.update_columns(error_message: e.message.truncate(255), state: :failed)
        ::GraphqlTriggers.security_policy_schedule_test_run_updated(test_run.reset)

        raise
      end
    end
  end
end
