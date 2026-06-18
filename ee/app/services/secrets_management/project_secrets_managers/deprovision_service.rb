# frozen_string_literal: true

module SecretsManagement
  module ProjectSecretsManagers
    class DeprovisionService < BaseDeprovisionService
      private

      def lease_key_prefix
        'project_secret_operation'
      end

      def entity_path
        maintenance_task.project_path
      end

      # Match on the cached `project_path` so we still find the SM
      # after the parent project has been destroyed and `SM.project_id`
      # was nulled by `ON DELETE SET NULL`. `project_path` is set once
      # in the `before_create` callback and never changes, so it is the
      # only identifier on the SM that survives the cascade.
      #
      # `project_path` has no index, so this is a seq scan. The table
      # is tiny (Open Beta) and this lookup is transitional: a follow-up
      # MR in the same 19.1 milestone, landing right after the DELETE
      # trigger (gitlab-org/gitlab#600290), removes this method
      # entirely because the worker will no longer need the SM record.
      def find_secrets_manager
        ProjectSecretsManager.find_by(project_path: maintenance_task.project_path) # rubocop:disable CodeReuse/ActiveRecord -- transitional lookup; will be removed in the trigger follow-up
      end

      def payload_key
        :project_secrets_manager_maintenance_task
      end

      def execute_deprovision
        namespace_id = find_secrets_manager&.namespace_id_for_secret_count
        response = super
        enqueue_namespace_secret_count_refresh(namespace_id) if response&.success?
        response
      end

      def enqueue_namespace_secret_count_refresh(namespace_id)
        return unless namespace_id

        ReconcileNamespaceSecretCountWorker.perform_async(namespace_id, current_user&.id)
      end
    end
  end
end
