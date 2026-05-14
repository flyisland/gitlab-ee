# frozen_string_literal: true

module Security
  module PipelineExecutionPolicies
    class TestRunService
      include Gitlab::Utils::StrongMemoize

      def initialize(policy:, project:, user:)
        @policy = policy
        @project = project
        @user = user
      end

      def execute
        return error('Feature not available') if Feature.disabled?(:security_policies_spep_dry_run, project)
        return error('Policy must be a pipeline_execution_schedule_policy') unless valid_policy_type?
        return error('User is not allowed to trigger test runs for this policy') unless authorized_user?
        return error('Project is not in policy scope') unless project_in_scope?

        test_run = create_test_run
        return error(test_run.errors.full_messages.join(', ')) unless test_run.persisted?

        execute_pipeline(test_run)
      end

      private

      attr_reader :policy, :project, :user

      def valid_policy_type?
        policy.type_pipeline_execution_schedule_policy?
      end

      def project_in_scope?
        policy.scope_applicable?(project)
      end

      def authorized_user?
        Ability.allowed?(user, :create_policy_schedule_test_run, project)
      end

      def create_test_run
        Security::ScheduledPipelineExecutionPolicyTestRun.create(
          security_policy: policy,
          project: project
        )
      end

      def execute_pipeline(test_run)
        result = CreateScheduledPipelineService.new(
          project: project,
          ci_content: policy.content['content'],
          policy_id: policy.id
        ).execute

        if result.success?
          pipeline = result.payload
          test_run.update!(pipeline: pipeline, state: :running)
          success(test_run: test_run, pipeline: pipeline)
        else
          test_run.update!(error_message: result.message, state: :failed)
          error(result.message, test_run: test_run)
        end
      end

      def success(payload = {})
        ServiceResponse.success(payload: payload)
      end

      def error(message, payload = {})
        ServiceResponse.error(message: message, payload: payload)
      end
    end
  end
end
