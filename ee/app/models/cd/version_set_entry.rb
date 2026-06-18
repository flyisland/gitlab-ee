# frozen_string_literal: true

module Cd
  class VersionSetEntry < ApplicationRecord
    self.table_name = 'cd_version_set_entries'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    belongs_to :version_set, class_name: 'Cd::VersionSet', inverse_of: :version_set_entries, optional: false
    belongs_to :version, class_name: 'Cd::Version', inverse_of: :version_set_entries, optional: false
    belongs_to :service, class_name: 'Cd::Service', optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :deployments, class_name: 'Cd::Deployment', inverse_of: :version_set_entry

    populate_sharding_key :organization_id, source: :version_set

    before_validation :populate_service_id

    validates :version_id, uniqueness: { scope: :version_set_id }
    validates :service_id, uniqueness: { scope: :version_set_id,
                                         message: ->(*) { _('already has an entry in this version set') } }

    private

    def populate_service_id
      self.service_id ||= version&.artifact_source&.service_id
    end
  end
end
