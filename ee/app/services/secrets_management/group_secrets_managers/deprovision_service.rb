# frozen_string_literal: true

module SecretsManagement
  module GroupSecretsManagers
    class DeprovisionService < BaseDeprovisionService
      private

      def lease_key_prefix
        'group_secret_operation'
      end

      def execute_deprovision
        namespace_id = find_secrets_manager&.namespace_id_for_secret_count
        response = super
        enqueue_namespace_secret_count_refresh(namespace_id) if response&.success?
        response
      end

      def entity_path
        maintenance_task.group_path
      end

      # Match on the cached `group_path` so we still find the SM after
      # the parent group has been destroyed and `SM.group_id` was
      # nulled by `ON DELETE SET NULL`. `group_path` is set once in
      # the `before_create` callback and never changes, so it is the
      # only identifier on the SM that survives the cascade.
      #
      # `group_path` has no index, so this is a seq scan. The table is
      # tiny (Open Beta) and this lookup is transitional: a follow-up
      # MR in the same 19.1 milestone, landing right after the DELETE
      # trigger (gitlab-org/gitlab#600290), removes this method
      # entirely because the worker will no longer need the SM record.
      def find_secrets_manager
        GroupSecretsManager.find_by(group_path: maintenance_task.group_path) # rubocop:disable CodeReuse/ActiveRecord -- transitional lookup; will be removed in the trigger follow-up
      end

      def payload_key
        :group_secrets_manager_maintenance_task
      end

      def enqueue_namespace_secret_count_refresh(namespace_id)
        return unless namespace_id

        ReconcileNamespaceSecretCountWorker.perform_async(namespace_id, current_user&.id)
      end
    end
  end
end
