# frozen_string_literal: true

module SecretsManagement
  class GroupSecretsManager < BaseSecretsManager
    include GroupSecretsManagers::PipelineHelper
    include GroupSecretsManagers::UserHelper
    include SecretsManagers::PathBuilder

    DEFAULT_SECRETS_LIMIT = 500

    self.table_name = 'group_secrets_managers'

    # `group_id` is nullable on purpose, and the foreign key in the
    # database is `ON DELETE SET NULL`. When a group is destroyed, this
    # row sticks around with `group_id = NULL` instead of disappearing.
    #
    # That's not an oversight; it's how we detect orphans. If the async
    # OpenBao cleanup never happens (DB hiccup, OOM, the worker dies),
    # the secrets manager row is left in the database as a clear signal
    # that something needs cleanup. The orphan reaper just runs
    # `where(group_id: nil)` and reconciles. See gitlab-org/gitlab#600120.
    #
    # PLEASE DO NOT change this FK to `ON DELETE CASCADE`. That would
    # destroy the rows the reaper relies on to find orphans.
    belongs_to :group, inverse_of: :secrets_manager

    scope :with_group, -> { includes(:group) }

    validates :group, presence: true

    # Cache the OpenBao path the SM was provisioned at, so the orphan
    # reaper (gitlab-org/gitlab#600120) can deprovision OpenBao state
    # for SMs whose group has been destroyed. Once group_id is NULL we
    # cannot compute the path from the live record anymore.
    #
    # The column setters intentionally bypass the `root_namespace_path`
    # / `group_path` method overrides below (which return live single
    # segments for the 3-step provisioning client flow). The cached
    # columns store the full 2-segment prefix and the entity segment
    # respectively, so the reaper can reconstruct the full path via
    # `read_attribute(:root_namespace_path) + '/' + read_attribute(:group_path)`.
    before_create :set_cached_paths

    class << self
      def build_group_path(group_id)
        "group_#{group_id}"
      end

      def build_full_group_namespace_path(organization_id:, root_namespace_id:, group_id:)
        [
          build_org_path(organization_id),
          build_root_namespace_path(root_namespace_id),
          build_group_path(group_id)
        ].join('/')
      end
    end

    def org_path
      self.class.build_org_path(group.organization_id)
    end

    def root_namespace_path
      self.class.build_root_namespace_path(group.root_ancestor.id)
    end

    def group_path
      self.class.build_group_path(group.id)
    end

    def full_group_namespace_path
      [org_path, root_namespace_path, group_path].join('/')
    end
    alias_method :full_namespace_path, :full_group_namespace_path

    def secrets_limit
      Gitlab::CurrentSettings.group_secrets_limit || DEFAULT_SECRETS_LIMIT
    end

    def namespace_id_for_secret_count
      group_id
    end

    private

    def set_cached_paths
      root_ancestor_id = group.root_ancestor.id

      self[:root_namespace_path] = [
        self.class.build_org_path(group.organization_id),
        self.class.build_root_namespace_path(root_ancestor_id)
      ].join('/')
      self[:group_path] = self.class.build_group_path(group.id)

      # Denormalize the ids the trigger-based deprovision flow reads off
      # the SM row at delete time. See gitlab-org/gitlab#600290.
      self[:organization_id] = group.organization_id
      self[:root_namespace_id] = root_ancestor_id
    end
  end
end
