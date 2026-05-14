# frozen_string_literal: true

module SecretsManagement
  class GroupSecretsManager < BaseSecretsManager
    include GroupSecretsManagers::PipelineHelper
    include GroupSecretsManagers::UserHelper

    DEFAULT_SECRETS_LIMIT = 500

    self.table_name = 'group_secrets_managers'

    belongs_to :group, inverse_of: :secrets_manager

    validates :group, presence: true

    before_create :set_group_path
    before_create :set_root_namespace_path

    def full_group_namespace_path
      [root_namespace_path, group_path].join('/')
    end

    def secrets_limit
      Gitlab::CurrentSettings.group_secrets_limit || DEFAULT_SECRETS_LIMIT
    end

    private

    def set_group_path
      self.group_path = "group_#{group.id}"
    end

    def set_root_namespace_path
      self.root_namespace_path = "group_#{group.root_ancestor.id}"
    end
  end
end
