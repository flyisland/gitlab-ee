# frozen_string_literal: true

module Cd
  class RolloutEnvironment < ApplicationRecord
    self.table_name = 'cd_rollout_environments'

    belongs_to :rollout, class_name: 'Cd::Rollout', inverse_of: :rollout_environments, optional: false
    belongs_to :environment, class_name: 'Cd::Environment', inverse_of: :rollout_environments, optional: false
    belongs_to :driver_binding, class_name: 'Cd::EnvironmentDriverBinding', inverse_of: :rollout_environments,
      optional: false
    belongs_to :previous_version_set, class_name: 'Cd::VersionSet', inverse_of: :rollout_environments, optional: true
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :deployments, class_name: 'Cd::Deployment', inverse_of: :rollout_environment

    populate_sharding_key :organization_id, source: :rollout

    scope :ordered, -> { order(position: :asc) }

    validates :position, presence: true
    validates :environment_id, uniqueness: { scope: :rollout_id,
                                             message: ->(*) { _('already has a rollout environment in this rollout') } }

    enum :state, {
      pending: 0,
      in_progress: 1,
      paused: 2,
      completed: 3,
      failed: 4,
      cancelled: 5
    }
  end
end
