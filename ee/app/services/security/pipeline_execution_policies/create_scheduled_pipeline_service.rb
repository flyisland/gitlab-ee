# frozen_string_literal: true

module Security
  module PipelineExecutionPolicies
    class CreateScheduledPipelineService
      PIPELINE_SOURCE = :pipeline_execution_policy_schedule
      EVENT_KEY = 'scheduled_pipeline_execution_policy_failure'

      def initialize(project:, ci_content:, branch: nil, policy_id: nil, schedule_id: nil)
        @project = project
        @ci_content = ci_content
        @branch = branch || project.default_branch_or_main
        @policy_id = policy_id
        @schedule_id = schedule_id
      end

      def execute
        ensure_security_policy_bot

        create_pipeline.tap do |result|
          log_pipeline_creation_failure(result) if result.error?
        end
      end

      private

      attr_reader :project, :ci_content, :branch, :policy_id, :schedule_id

      def create_pipeline
        yaml_content = ci_content.deep_stringify_keys.to_yaml
        Ci::CreatePipelineService.new(
          project,
          project.security_policy_bot,
          ref: branch
        ).execute(PIPELINE_SOURCE, content: yaml_content, ignore_skip_ci: true)
      end

      def ensure_security_policy_bot
        return if project.security_policy_bot

        Security::Orchestration::CreateBotService
          .new(project, nil, skip_authorization: true)
          .execute

        project.reset
      end

      def log_pipeline_creation_failure(result)
        Gitlab::AppJsonLogger.error(
          event: EVENT_KEY,
          message: result.message,
          reason: result.reason,
          project_id: project.id,
          schedule_id: schedule_id,
          policy_id: policy_id,
          branch: branch
        )
      end
    end
  end
end
