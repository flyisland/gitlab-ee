# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Validate
            module Abilities
              extend ::Gitlab::Utils::Override

              override :perform!
              def perform!
                # We check for `builds_enabled?` here so that this error does
                # not get produced before the "pipelines are disabled" error.
                if project.builds_enabled? && mirror_update? && !project.mirror_trigger_builds?
                  return error('Pipeline is disabled for mirror updates')
                end

                super
              end

              private

              override :allowed_to_run_pipeline?
              def allowed_to_run_pipeline?
                # For on-demand DAST scans, only security managers (with :_run_dast_pipeline)
                # can bypass branch protection. Other users with :create_on_demand_dast_scan
                # must still have branch access (checked by super).
                if command.ondemand_dast_scan? && can?(current_user, :create_on_demand_dast_scan,
                  project) && can?(current_user, :_run_dast_pipeline, project)
                  return true
                end

                super || allowed_via_protected_branch_bypass?
              end

              # Mirror the approval policy bypass that let the push reach a protected
              # branch (see EE::Gitlab::Checks::BranchCheck); otherwise the push
              # pipeline is silently discarded. Scoped to push-created pipelines: the
              # push path already evaluated and audited the bypass, so auditing is off
              # here. Other sources (web, schedule, api) never run the push path, so
              # they must not silently inherit the bypass without an audit trail.
              def allowed_via_protected_branch_bypass?
                return false unless current_user && command.branch? && command.source&.to_sym == :push

                ::Security::ScanResultPolicies::CombinedBypassChecker.new(
                  project: project,
                  user_access: user_access,
                  branch_name: command.ref,
                  push_options: command.push_options,
                  audit: false
                ).protected_branch_bypass_granted?
              end

              def mirror_update?
                # - command.mirror_update is for in-place pipeline creation within pull mirroring.
                # - gitaly_context is for pipelines created from post-receive hooks
                command.mirror_update ||
                  command.gitaly_context&.fetch(::Projects::UpdateMirrorService::GITALY_CONTEXT_KEY, false)
              end
            end
          end
        end
      end
    end
  end
end
