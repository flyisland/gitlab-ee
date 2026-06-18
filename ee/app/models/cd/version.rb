# frozen_string_literal: true

module Cd
  class Version < ApplicationRecord
    self.table_name = 'cd_versions'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    belongs_to :artifact_source, class_name: 'Cd::ArtifactSource', inverse_of: :versions, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :version_set_entries, class_name: 'Cd::VersionSetEntry', inverse_of: :version

    populate_sharding_key :organization_id, source: :artifact_source

    validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :artifact_source_id },
      format: { with: Gitlab::Regex.cd_name_regex, message: Gitlab::Regex.cd_name_regex_message }
    validates :digest, length: { maximum: 255 }
    validates :reference, length: { maximum: 1024 }
  end
end
