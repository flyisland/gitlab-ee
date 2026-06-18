# frozen_string_literal: true

module SecretsManagement
  module GroupSecretsManagers
    class InitializeService < GroupBaseService
      include InitializeServiceHelpers

      private

      def resource
        group
      end

      def create_secrets_manager
        GroupSecretsManager.create!(group: group)
      end

      def create_maintenance_task(_secrets_manager)
        GroupSecretsManagerMaintenanceTask.create!(
          user: current_user,
          group_id: group.id,
          organization_id: group.organization_id,
          root_namespace_id: group.root_ancestor.id,
          action: :provision,
          last_processed_at: Time.zone.now
        )
      end

      def enqueue_provision_worker(task)
        ProvisionGroupSecretsManagerTaskWorker.perform_async(task.id)
      end
    end
  end
end
