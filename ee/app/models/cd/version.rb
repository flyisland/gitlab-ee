# frozen_string_literal: true

module Cd
  class Version < ApplicationRecord
    self.table_name = 'cd_versions'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    belongs_to :artifact_source, class_name: 'Cd::ArtifactSource', inverse_of: :versions, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :version_set_entries, class_name: 'Cd::VersionSetEntry', inverse_of: :version

    populate_sharding_key :organization_id, source: :artifact_source

    scope :for_application, ->(application) {
      joins(artifact_source: :service).where(cd_services: { application_id: application })
    }
    scope :for_artifact_sources, ->(artifact_sources) { where(artifact_source_id: artifact_sources) }
    scope :with_name, ->(name) { where(name: name) }
    scope :preload_artifact_source_and_service, -> { preload(artifact_source: :service) }

    validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :artifact_source_id },
      format: { with: Gitlab::Regex.cd_name_regex, message: Gitlab::Regex.cd_name_regex_message }
    validates :digest, length: { maximum: 255 }
    validates :reference, length: { maximum: 1024 }
  end
end
