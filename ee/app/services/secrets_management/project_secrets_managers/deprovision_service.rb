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

      def find_secrets_manager
        ProjectSecretsManager.find_by_id(maintenance_task.project_secrets_manager_id)
      end

      def payload_key
        :project_secrets_manager_maintenance_task
      end
    end
  end
end
