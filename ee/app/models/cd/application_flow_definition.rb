# frozen_string_literal: true

module Cd
  class ApplicationFlowDefinition < ApplicationRecord
    include FileStoreMounter

    self.table_name = 'cd_application_flow_definitions'

    DEFINITION_SIZE_LIMIT = 1.megabyte

    belongs_to :application, class_name: 'Cd::Application', inverse_of: :application_flow_definitions, optional: false

    mount_file_store_uploader Cd::ApplicationFlowDefinitionUploader

    populate_sharding_key :organization_id do
      application&.organization_id || application&.group&.organization_id
    end

    before_validation :assign_next_version, on: :create
    before_update :prevent_modification

    validates :version, presence: true,
      numericality: { only_integer: true, greater_than: 0 },
      uniqueness: { scope: :application_id }
    validates :definition, presence: true, length: { maximum: DEFINITION_SIZE_LIMIT }
    validate :application_belongs_to_organization

    scope :for_application, ->(application_id) { where(application_id: application_id) }
    scope :ordered, -> { order(version: :desc) }

    def definition
      return @definition if defined?(@definition)

      @definition = file.read&.force_encoding(Encoding::UTF_8)
    end

    def definition=(content)
      prevent_modification if persisted?

      @definition = content

      self.file = CarrierWaveStringFile.new(content) if content
    end

    def revert_to_previous_version
      previous = versions.where(version: ...version).ordered.first
      return unless previous

      self.class.create!(
        application_id: application_id,
        organization_id: organization_id,
        definition: previous.definition
      )
    end

    private

    def versions
      self.class.for_application(application_id)
    end

    def assign_next_version
      return if version_changed? || application.blank?

      self.version = (versions.maximum(:version) || 0) + 1
    end

    def prevent_modification
      raise ActiveRecord::ReadOnlyRecord, "#{self.class.name} is append-only and cannot be modified"
    end

    def application_belongs_to_organization
      return if application.blank? || organization_id.blank?
      return if application.organization_id == organization_id
      return if application.group&.organization_id == organization_id

      errors.add(:application, _('must belong to the same organization.'))
    end
  end
end
