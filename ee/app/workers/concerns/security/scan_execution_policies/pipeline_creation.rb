# frozen_string_literal: true

# Shared logic for workers that create pipelines from scan execution policies.
# Used by CreatePipelineWorker and RunScheduleWorker.
module Security
  module ScanExecutionPolicies
    module PipelineCreation
      extend ActiveSupport::Concern

      included do
        include Gitlab::InternalEventsTracking
      end

      private

      def actions_for(rule_schedule)
        policy = rule_schedule.policy
        return [] if policy.blank?

        actions = policy[:actions]
        action_limit = Gitlab::CurrentSettings.scan_execution_policies_action_limit

        return actions if action_limit == 0

        actions.first(action_limit)
      end

      def create_scan_execution_pipeline(project:, user:, rule_schedule:, branch:)
        actions = actions_for(rule_schedule)
        return if actions.blank?

        policy_name = rule_schedule.policy[:name]
        service_result = ::Security::SecurityOrchestrationPolicies::CreatePipelineService
                  .new(project: project, current_user: user,
                    params: { actions: actions, branch: branch, policy_name: policy_name })
                  .execute

        track_creation_event(project, rule_schedule, actions.size, service_result[:status])

        return unless service_result[:status] == :error

        log_pipeline_creation_error(project, user, rule_schedule, branch, service_result[:message])

        ::Security::Policies::ScheduledScansNotEnforcedAuditWorker.perform_async(
          project.id, user.id, rule_schedule.id, branch
        )
      end

      def track_creation_event(project, rule_schedule, scans_count, result)
        track_internal_event(
          'enforce_scheduled_scan_execution_policy_in_project',
          project: project,
          additional_properties: {
            value: scans_count,
            label: result.to_s,
            property: rule_schedule.policy_source,
            time_window: rule_schedule.time_window.present? ? 1 : 0
          }
        )
      end

      def log_pipeline_creation_error(project, user, rule_schedule, branch, message)
        ::Gitlab::AppJsonLogger.warn(
          build_structured_payload(
            message: message,
            project_id: project.id,
            Labkit::Fields::GL_USER_ID => user.id,
            security_orchestration_policy_configuration_id:
              rule_schedule.security_orchestration_policy_configuration_id,
            rule_schedule_id: rule_schedule.id,
            branch: branch
          )
        )
      end
    end
  end
end
