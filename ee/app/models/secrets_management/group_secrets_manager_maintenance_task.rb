# frozen_string_literal: true

module SecretsManagement
  class GroupSecretsManagerMaintenanceTask < BaseSecretsManagerMaintenanceTask
    include MaintenanceTaskPathResolver

    self.table_name = 'group_secrets_manager_maintenance_tasks'

    secrets_manager_class GroupSecretsManager

    belongs_to :group

    validates :group_id, uniqueness: true
    validates :group_id, presence: true
    validates :organization_id, presence: true

    scope :for_group, ->(group_id) { where(group_id: group_id) }
    scope :order_by_id_asc, -> { order(:id) }

    def secrets_manager
      GroupSecretsManager.find_by_group_id(group_id)
    end

    def group_path
      GroupSecretsManager.build_group_path(group_id)
    end

    def full_group_namespace_path
      GroupSecretsManager.build_full_group_namespace_path(
        organization_id: organization_id,
        root_namespace_id: root_namespace_id,
        group_id: group_id
      )
    end
    alias_method :full_namespace_path, :full_group_namespace_path
  end
end
