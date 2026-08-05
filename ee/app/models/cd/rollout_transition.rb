# frozen_string_literal: true

module Cd
  class RolloutTransition < ApplicationRecord
    self.table_name = 'cd_rollout_transitions'

    ignore_column :principal_type, remove_with: '19.3', remove_after: '2026-07-17'
    ignore_column :principal_id, remove_with: '19.4', remove_after: '2026-08-21'

    STATES = {
      initial: 0,
      pending: 1,
      in_progress: 2,
      paused: 3,
      completed: 4,
      failed: 5,
      cancelled: 6
    }.freeze

    belongs_to :rollout, class_name: 'Cd::Rollout', inverse_of: :rollout_transitions, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false

    populate_sharding_key :organization_id, source: :rollout

    scope :ordered, -> { order(created_at: :asc) }

    validates :event, presence: true, length: { maximum: 72 }
    validates :from_state, presence: true
    validates :to_state, presence: true
    validates :principal, presence: true, length: { maximum: 255 }
    validates :on_behalf_of, length: { maximum: 255 }
    validates :reason, length: { maximum: 2000 }
    validates :triggered_by, length: { maximum: 255 }

    enum :from_state, STATES, prefix: :from
    enum :to_state, STATES, prefix: :to

    def readonly?
      persisted?
    end
  end
end
