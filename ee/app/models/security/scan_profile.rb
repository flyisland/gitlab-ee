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

    enum :scan_type, Enums::Security.security_profile_types

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
    validates :configuration, json_schema: {
      filename: 'security_profile_scan_configuration',
      size_limit: 64.kilobytes,
      detail_errors: true
    }, if: :scanner?
    validate :validate_post_processing_configuration, if: :post_processing?

    before_validation :set_triggers_namespace

    scope :by_namespace, ->(namespace) { where(namespace: namespace) }
    scope :by_type, ->(type) { where(scan_type: type) }
    scope :by_gitlab_recommended, ->(gitlab_recommended = true) { where(gitlab_recommended: gitlab_recommended) }
    scope :with_trigger_type, ->(trigger_type) {
      joins(:scan_profile_triggers).where(security_scan_profile_triggers: { trigger_type: trigger_type })
    }
    scope :scanner, -> { where(scan_type: Enums::Security.scan_profile_types.keys) }
    scope :post_processing, -> { where(scan_type: Enums::Security.post_processing_scan_profile_types.keys) }

    def self.scan_type_names_for_project(project)
      return [] unless project

      project.security_scan_profiles
        .scanner
        .distinct
        .limit(Enums::Security.scan_profile_types.size)
        .pluck(:scan_type)
    end

    def self.scan_profile_ids(limit = MAX_PLUCK)
      limit(limit).ids
    end

    def ci_template_name
      CI_TEMPLATE_NAMES.fetch(scan_type&.to_sym, DEFAULT_CI_TEMPLATE_NAME)
    end

    def effective_configuration(project: nil)
      Security::ScanProfiles::Configuration.for(self, project: project)
    end

    def post_processing?
      Enums::Security.post_processing_scan_profile_types.key?(scan_type&.to_sym)
    end

    def scanner?
      Enums::Security.scan_profile_types.key?(scan_type&.to_sym)
    end

    private

    def root_namespace_validation
      errors.add(:namespace, 'must be a root namespace.') unless namespace&.root?
    end

    def validate_post_processing_configuration
      JsonSchemaValidator.new({
        attributes: :configuration,
        filename: json_schema_filename,
        size_limit: 64.kilobytes,
        detail_errors: true
      }).validate(self)
    rescue RuntimeError => e
      raise unless e.message.include?('No json validation schema')

      errors.add(:configuration, "schema not found for scan type '#{scan_type}'")
    end

    def json_schema_filename
      "security_profile_#{scan_type}_configuration"
    end

    def set_triggers_namespace
      scan_profile_triggers.each do |trigger|
        trigger.namespace ||= namespace
      end
    end
  end
end
