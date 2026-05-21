# frozen_string_literal: true

module SecretsManagement
  class DeprovisionProjectSecretsManagerWorker
    include ApplicationWorker

    data_consistency :sticky

    urgency :high

    idempotent!

    feature_category :secrets_management

    def perform(maintenance_task_id)
      task = ProjectSecretsManagerMaintenanceTask.find_by_id(maintenance_task_id)
      return unless task

      user = User.find_by_id(task.user_id)
      return unless user

      ProjectSecretsManagers::DeprovisionService.new(task, user).execute
    end
  end
end
