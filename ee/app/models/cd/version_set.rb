# frozen_string_literal: true

module Cd
  class VersionSet < ApplicationRecord
    self.table_name = 'cd_version_sets'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    ignore_column :environment_id, remove_with: '19.2', remove_after: '2026-07-15'

    belongs_to :application, class_name: 'Cd::Application', inverse_of: :version_sets, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :version_set_entries, class_name: 'Cd::VersionSetEntry', inverse_of: :version_set
    has_many :versions, through: :version_set_entries
    has_many :rollouts, class_name: 'Cd::Rollout', inverse_of: :version_set

    populate_sharding_key :organization_id, source: :application

    validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :application_id },
      format: { with: Gitlab::Regex.cd_name_regex, message: Gitlab::Regex.cd_name_regex_message }
  end
end
