# frozen_string_literal: true

module Security
  module PipelineExecutionSchedulePolicies
    class TestRunCompletionWorker
      include Gitlab::EventStore::Subscriber

      feature_category :security_policy_management
      data_consistency :sticky
      idempotent!
      deduplicate :until_executing, including_scheduled: true

      def handle_event(event)
        pipeline_id = event.data[:pipeline_id]
        status = event.data[:status]

        test_run = ::Security::ScheduledPipelineExecutionPolicyTestRun.for_pipeline_id(pipeline_id).first
        unless test_run
          Gitlab::AppLogger.error(structured_payload(message: 'Test run not found for pipeline',
            pipeline_id: pipeline_id))
          return
        end

        new_state = status == 'failed' ? :failed : :complete
        test_run.update!(state: new_state)
      end
    end
  end
end
