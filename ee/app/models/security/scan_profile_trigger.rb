# frozen_string_literal: true

module Security
  class ScanProfileTrigger < ::SecApplicationRecord
    self.table_name = 'security_scan_profile_triggers'

    PIPELINE_RELATED_TRIGGER_TYPE = %w[
      default_branch_pipeline
      merge_request_pipeline
    ].freeze

    POST_PROCESSING_TRIGGER_TYPE = %w[
      sbom_ingested
    ].freeze

    belongs_to :namespace, optional: false
    belongs_to :scan_profile, class_name: 'Security::ScanProfile', foreign_key: :security_scan_profile_id,
      inverse_of: :scan_profile_triggers, optional: false

    enum :trigger_type, Enums::Security.scan_profile_trigger_types

    validates :trigger_type, presence: true
    validates :security_scan_profile_id, uniqueness: { scope: :trigger_type }
    validate :trigger_type_compatible_with_profile

    private

    def pipeline_trigger?
      PIPELINE_RELATED_TRIGGER_TYPE.include?(trigger_type.to_s)
    end

    def post_processing_trigger?
      POST_PROCESSING_TRIGGER_TYPE.include?(trigger_type.to_s)
    end

    def trigger_type_compatible_with_profile
      return unless scan_profile

      if scan_profile.post_processing? && pipeline_trigger?
        errors.add(:trigger_type, 'is not allowed on post processing scan profiles')
      elsif post_processing_trigger? && !scan_profile.post_processing?
        errors.add(:trigger_type, 'is only allowed on post processing scan profiles')
      end
    end
  end
end
