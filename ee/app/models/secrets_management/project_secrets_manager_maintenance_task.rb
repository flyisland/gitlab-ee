# frozen_string_literal: true

module SecretsManagement
  class ProjectSecretsManagerMaintenanceTask < BaseSecretsManagerMaintenanceTask
    include MaintenanceTaskPathResolver

    self.table_name = 'project_secrets_manager_maintenance_tasks'

    secrets_manager_class ProjectSecretsManager

    belongs_to :project_secrets_manager,
      class_name: 'SecretsManagement::ProjectSecretsManager'
    belongs_to :project
    belongs_to :parent_group,
      class_name: 'Group'

    validates :action, uniqueness: { scope: :project_secrets_manager_id }
    validates :project_id, uniqueness: true
    validates :project_secrets_manager_id, presence: true
    validates :project_id, presence: true
    validates :parent_group_id, presence: true

    scope :for_secrets_manager, ->(secrets_manager_id) { where(project_secrets_manager_id: secrets_manager_id) }
    scope :order_by_id_asc, -> { order(:id) }

    def project_path
      ProjectSecretsManager.build_project_path(project_id)
    end

    def full_project_namespace_path
      ProjectSecretsManager.build_full_project_namespace_path(
        organization_id: organization_id,
        root_namespace_id: root_namespace_id,
        project_id: project_id
      )
    end
    alias_method :full_namespace_path, :full_project_namespace_path
  end
end
