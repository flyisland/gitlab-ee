# frozen_string_literal: true

module EE
  module Ci
    module Pipelines
      module HookService
        def execute
          super
          execute_flow_triggers
        end

        private

        def execute_flow_triggers
          return unless ::Feature.enabled?(:ai_flow_trigger_pipeline_hooks, project.root_group)
          return unless pipeline.complete?

          # Do not trigger flows for pipelines that are controlled by GitLab.
          # Pipeline sources excluded from AI Flows (e.g., auto-fix):
          # - webide: Deprecated but may have lingering pipelines
          # - ondemand_dast_scan/ondemand_dast_validation: Ad-hoc user-triggered scans
          #   from Security UI; failures handled by vulnerability features
          # - security_orchestration_policy: Forced scans on projects without .gitlab-ci.yml;
          #   keep non-invasive since projects aren't pipeline-equipped
          # - pipeline_execution_policy_schedule: Group-level scheduled policies; auto-fix
          #   could introduce confusion for downstream projects (especially in large groups)
          # - container_registry_push: Event-based scans on image push; auto-fix lacks
          #   context of original uploader (exploring push-blocking instead)
          # - duo_workflow: Blocked to prevent recursive triggers
          return if ::Enums::Ci::Pipeline.gitlab_controlled_sources.key?(pipeline.source)

          project.execute_flow_triggers(hook_data, ::Ci::Pipelines::HookService::HOOK_NAME)
        end
      end
    end
  end
end
