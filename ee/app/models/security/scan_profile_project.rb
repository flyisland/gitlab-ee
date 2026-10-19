# frozen_string_literal: true

module Security
  class ScanProfileProject < ::SecApplicationRecord
    self.table_name = 'security_scan_profiles_projects'

    MAX_PROFILES_PER_PROJECT = 10

    belongs_to :project, optional: false
    belongs_to :scan_profile, class_name: 'Security::ScanProfile', foreign_key: :security_scan_profile_id,
      inverse_of: :scan_profile_projects, optional: false

    validates :project_id, uniqueness: { scope: :security_scan_profile_id }

    scope :for_projects_and_profile, ->(projects, scan_profile) {
      where(project: projects, scan_profile: scan_profile)
    }

    scope :by_project_id, ->(project_id) { where(project_id: project_id) }
    scope :unarchived, -> { where(archived: false) }
    scope :for_scan_profiles, ->(scan_profile_ids) { where(security_scan_profile_id: scan_profile_ids) }
    scope :not_in_root_namespace, ->(root_namespace) {
      joins(:scan_profile).where.not(security_scan_profiles: { namespace: root_namespace })
    }

    def self.project_ids
      limit(MAX_PLUCK).pluck(:project_id)
    end

    def self.attached_project_ids(project_ids)
      return [] if project_ids.blank?

      by_project_id(project_ids)
        .distinct
        .limit(project_ids.size)
        .pluck(:project_id)
    end

    def self.sync_archived_for(project_ids)
      projects = preload_archived_state(::Project.id_in(project_ids).to_a)

      archived, unarchived = projects.partition(&:self_or_ancestors_archived?)

      update_archived_for(archived.map(&:id), archived: true) +
        update_archived_for(unarchived.map(&:id), archived: false)
    end

    def self.preload_archived_state(projects)
      ::ActiveRecord::Associations::Preloader.new(
        records: projects,
        associations: [:project_namespace, { namespace: :namespace_settings_with_ancestors_inherited_settings }]
      ).call

      projects
    end

    def self.update_archived_for(project_ids, archived:)
      return 0 if project_ids.blank?

      by_project_id(project_ids)
        .where.not(archived: archived)
        .update_all(archived: archived, updated_at: Time.current)
    end
  end
end
