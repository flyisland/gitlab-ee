# frozen_string_literal: true

module Cd
  class ArtifactSource < ApplicationRecord
    self.table_name = 'cd_artifact_sources'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    enum :source_type, {
      internal_pipeline: 0,
      external_registry: 1,
      desired_state: 2
    }

    belongs_to :service, class_name: 'Cd::Service', inverse_of: :artifact_source, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    belongs_to :project, optional: true
    has_many :versions, class_name: 'Cd::Version', inverse_of: :artifact_source

    populate_sharding_key :organization_id, source: :service

    validates :service_id, uniqueness: true
    validates :project, presence: true, if: :internal_pipeline?
    validate :project_belongs_to_organization

    private

    def project_belongs_to_organization
      return unless project
      return if project.organization_id == organization_id

      errors.add(:project, _("must belong to the same organization."))
    end
  end
end
