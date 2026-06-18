# frozen_string_literal: true

module Security
  class ScanProfile < ::SecApplicationRecord
    include StripAttribute

    DEFAULT_CI_TEMPLATE_NAME = 'default'
    CI_TEMPLATE_NAMES = {
      dependency_scanning: 'v2'
    }.freeze

    self.table_name = 'security_scan_profiles'
    strip_attributes! :name, :description

    belongs_to :namespace, optional: false

    enum :scan_type, Enums::Security.scan_profile_types

    has_many :scan_profile_projects, class_name: 'Security::ScanProfileProject',
      foreign_key: :security_scan_profile_id, inverse_of: :scan_profile
    has_many :projects, through: :scan_profile_projects
    has_many :security_scan_profile_project_statuses, class_name: 'Security::ScanProfileProjectStatus',
      foreign_key: :security_scan_profile_id, inverse_of: :scan_profile
    has_many :scan_profile_triggers, class_name: 'Security::ScanProfileTrigger',
      foreign_key: :security_scan_profile_id, inverse_of: :scan_profile

    accepts_nested_attributes_for :scan_profile_triggers

    validates :scan_type, presence: true
    validates :gitlab_recommended, inclusion: { in: [true, false] }
    validates :name, uniqueness: { scope: [:namespace_id, :scan_type] }, length: { maximum: 255 }, presence: true
    validates :description, length: { maximum: 2047 }, allow_blank: true
    validate :root_namespace_validation
    before_validation :set_triggers_namespace

    scope :by_namespace, ->(namespace) { where(namespace: namespace) }
    scope :by_type, ->(type) { where(scan_type: type) }
    scope :by_gitlab_recommended, ->(gitlab_recommended = true) { where(gitlab_recommended: gitlab_recommended) }
    scope :with_trigger_type, ->(trigger_type) {
      joins(:scan_profile_triggers).where(security_scan_profile_triggers: { trigger_type: trigger_type })
    }

    def self.scan_type_names_for_project(project)
      return [] unless project

      project.security_scan_profiles
        .distinct
        .limit(Enums::Security::SCAN_PROFILES_TYPES.size)
        .pluck(:scan_type)
    end

    def self.scan_profile_ids(limit = MAX_PLUCK)
      limit(limit).ids
    end

    def ci_template_name
      CI_TEMPLATE_NAMES.fetch(scan_type&.to_sym, DEFAULT_CI_TEMPLATE_NAME)
    end

    private

    def root_namespace_validation
      errors.add(:namespace, 'must be a root namespace.') unless namespace&.root?
    end

    def set_triggers_namespace
      scan_profile_triggers.each do |trigger|
        trigger.namespace ||= namespace
      end
    end
  end
end
