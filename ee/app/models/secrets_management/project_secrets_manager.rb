# frozen_string_literal: true

module SecretsManagement
  class ProjectSecretsManager < BaseSecretsManager
    include ProjectSecretsManagers::PipelineHelper
    include ProjectSecretsManagers::UserHelper
    include SecretsManagers::PathBuilder

    DEFAULT_SECRETS_LIMIT = 100

    self.table_name = 'project_secrets_managers'

    # `project_id` is nullable on purpose, and the foreign key in the
    # database is `ON DELETE SET NULL`. When a project is destroyed, this
    # row sticks around with `project_id = NULL` instead of disappearing.
    #
    # That's not an oversight; it's how we detect orphans. If the async
    # OpenBao cleanup never happens (DB hiccup, OOM, the worker dies),
    # the secrets manager row is left in the database as a clear signal
    # that something needs cleanup. The orphan reaper just runs
    # `where(project_id: nil)` and reconciles. See gitlab-org/gitlab#600120.
    #
    # PLEASE DO NOT change this FK to `ON DELETE CASCADE`. That would
    # destroy the rows the reaper relies on to find orphans.
    belongs_to :project, inverse_of: :secrets_manager

    validates :project, presence: true

    # Cache the OpenBao path the SM was provisioned at, so the orphan
    # reaper (gitlab-org/gitlab#600120) can deprovision OpenBao state
    # for SMs whose project has been destroyed. Once project_id is
    # NULL we cannot compute the path from the live record anymore.
    #
    # The column setters intentionally bypass the `namespace_path` /
    # `project_path` method overrides below (which return live single
    # segments for the 3-step provisioning client flow). The cached
    # columns store the full 2-segment prefix and the entity segment
    # respectively, so the reaper can reconstruct the full path via
    # `read_attribute(:namespace_path) + '/' + read_attribute(:project_path)`.
    before_create :set_cached_paths

    class << self
      def build_project_path(project_id)
        "project_#{project_id}"
      end

      def build_full_project_namespace_path(organization_id:, root_namespace_id:, project_id:)
        [
          build_org_path(organization_id),
          build_root_namespace_path(root_namespace_id),
          build_project_path(project_id)
        ].join('/')
      end
    end

    def org_path
      self.class.build_org_path(project.organization_id)
    end

    def namespace_path
      self.class.build_root_namespace_path(project.root_ancestor.id)
    end

    def project_path
      self.class.build_project_path(project.id)
    end

    def full_project_namespace_path
      [org_path, namespace_path, project_path].join('/')
    end
    alias_method :full_namespace_path, :full_project_namespace_path

    def secrets_limit
      Gitlab::CurrentSettings.project_secrets_limit || DEFAULT_SECRETS_LIMIT
    end

    private

    def set_cached_paths
      self[:namespace_path] = [
        self.class.build_org_path(project.organization_id),
        self.class.build_root_namespace_path(project.root_ancestor.id)
      ].join('/')
      self[:project_path] = self.class.build_project_path(project.id)
    end
  end
end
