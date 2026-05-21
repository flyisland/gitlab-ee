# frozen_string_literal: true

module SecretsManagement
  class GroupSecretsManagerMaintenanceTasksCronWorker < BaseMaintenanceTasksCronWorker
    idempotent!

    private

    def maintenance_task_class
      SecretsManagement::GroupSecretsManagerMaintenanceTask
    end

    def deprovision_worker_class
      SecretsManagement::DeprovisionGroupSecretsManagerWorker
    end
  end
end
