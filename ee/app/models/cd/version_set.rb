# frozen_string_literal: true

module Cd
  class VersionSet < ApplicationRecord
    self.table_name = 'cd_version_sets'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    ignore_column :environment_id, remove_with: '19.3', remove_after: '2026-08-15'

    belongs_to :application, class_name: 'Cd::Application', inverse_of: :version_sets, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :version_set_entries, class_name: 'Cd::VersionSetEntry', inverse_of: :version_set
    has_many :versions, through: :version_set_entries
    has_many :rollouts, class_name: 'Cd::Rollout', inverse_of: :version_set
    has_many :rollout_environments, class_name: 'Cd::RolloutEnvironment', inverse_of: :previous_version_set,
      foreign_key: :previous_version_set_id

    populate_sharding_key :organization_id, source: :application

    scope :in_organization, ->(organization) { where(organization_id: organization) }

    validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :application_id },
      format: { with: Gitlab::Regex.cd_name_regex, message: Gitlab::Regex.cd_name_regex_message }
    validates :entries_digest, uniqueness: { scope: :application_id }, allow_nil: true

    def compute_entries_digest
      fingerprints = version_set_entries.order(:artifact_source_id).map do |entry|
        "#{entry.artifact_source_id}:#{entry.version_id}"
      end

      return if fingerprints.empty?

      Digest::SHA256.hexdigest(fingerprints.join(','))
    end

    def update_entries_digest!
      update_column(:entries_digest, compute_entries_digest)
    end
  end
end
