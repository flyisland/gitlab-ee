# frozen_string_literal: true

module SecretsManagement
  module GroupSecretsManagers
    class DeprovisionService < BaseDeprovisionService
      private

      def lease_key_prefix
        'group_secret_operation'
      end

      def entity_path
        maintenance_task.group_path
      end

      # When the group is destroyed first (FK `ON DELETE SET NULL`),
      # `group_secrets_managers.group_id` is nulled before this worker
      # runs. The primary lookup by `group_id` returns nil in that
      # case. We fall back to the cached entity path, which encodes
      # the original group's id and is unique across SMs because group
      # ids are globally unique.
      #
      # The asymmetric structure here (project task has a direct FK to
      # the SM record, group task does not) is tracked as a follow-up
      # that will add `group_secrets_manager_id` to the group task
      # table and let this lookup use the same direct FK pattern as
      # the project flow.
      def find_secrets_manager
        GroupSecretsManager.find_by_group_id(maintenance_task.group_id) ||
          GroupSecretsManager.find_by(group_id: nil, group_path: maintenance_task.group_path) # rubocop:disable CodeReuse/ActiveRecord -- fallback lookup for orphaned SM; see comment above
      end

      def payload_key
        :group_secrets_manager_maintenance_task
      end
    end
  end
end
