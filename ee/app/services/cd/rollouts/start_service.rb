# frozen_string_literal: true

module Cd
  module Rollouts
    # Transitions a pending rollout to in_progress and starts the corresponding
    # AutoFlow workflow on KAS, persisting the returned workflow key.
    #
    # The rollout graph is passed to Gitlab::Kas::Client#start_workflow as plain
    # Ruby kwargs, which the client converts into AutoFlow protobuf values
    # (see https://gitlab.com/gitlab-org/gitlab/-/merge_requests/242249).
    #
    # For the Phase 0 demo the deploy driver reference is hardcoded until the
    # deploy driver gem is wired in
    # (see https://gitlab.com/gitlab-org/gitlab/-/work_items/602366).
    class StartService
      # Hardcoded for the demo until the deploy driver gem is wired in.
      DEMO_DRIVER_REF = 'argo-rollouts'

      def initialize(rollout)
        @rollout = rollout
      end

      def execute
        # Idempotent no-op: a previous attempt already started the workflow.
        return ServiceResponse.success(payload: { rollout: rollout }) if rollout.workflow_ref.present?

        return error(_('Rollout cannot be started because it is not pending.')) unless startable?

        # Call KAS before the database write so a slow or failing gRPC request does
        # not hold a transaction open. A KAS failure raises before any write,
        # leaving the rollout untouched (still pending, no workflow_ref) so the
        # idempotent worker can retry.
        response = kas_client.start_workflow(
          identity_key: identity_key,
          workflow_definition: workflow_definition,
          namespace_id: rollout.organization_id,
          kwargs: workflow_kwargs
        )

        # start! persists workflow_ref and the state transition in a single update.
        # workflow_ref is assigned first because a non-pending rollout requires it.
        rollout.workflow_ref = response.workflow_key
        rollout.start!

        ServiceResponse.success(payload: { rollout: rollout })
      end

      private

      attr_reader :rollout

      # Only a pending rollout can be started. A failed KAS call leaves the
      # rollout pending (the transition is persisted only after KAS succeeds), so
      # the idempotent worker always retries from pending.
      def startable?
        rollout.pending?
      end

      def kas_client
        @kas_client ||= ::Gitlab::Kas::Client.new
      end

      def identity_key
        "cd-rollout-#{rollout.id}"
      end

      # Raw (unencoded) deploy program. KAS executes the Starlark definition as-is
      # and fails if it is base64-encoded. Hardcoded for the demo.
      def workflow_definition
        "def main(w, *a, **k):\n    pass\n"
      end

      # The rollout graph passed as plain Ruby kwargs so AutoFlow can resolve the
      # environments, driver bindings and version set to deploy. Nested Hashes and
      # Arrays are converted to AutoFlow dict/list values by Gitlab::Kas::Client.
      def workflow_kwargs
        {
          'rollout' => rollout.id.to_s,
          'driver_ref' => DEMO_DRIVER_REF,
          'version_set' => rollout.version_set_id.to_s,
          'environments' => rollout.rollout_environments.ordered.map do |rollout_environment|
            {
              'position' => rollout_environment.position.to_s,
              'environment_id' => rollout_environment.environment_id.to_s,
              'driver_binding_id' => rollout_environment.driver_binding_id.to_s
            }
          end
        }
      end

      def error(message)
        ServiceResponse.error(message: Array(message), payload: { rollout: rollout })
      end
    end
  end
end
