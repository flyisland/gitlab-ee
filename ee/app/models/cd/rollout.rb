# frozen_string_literal: true

module Cd
  class Rollout < ApplicationRecord
    self.table_name = 'cd_rollouts'

    ignore_column :environment_id, remove_with: '19.3', remove_after: '2026-08-15'
    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    TERMINAL_STATES = %i[completed failed cancelled].freeze

    belongs_to :version_set, class_name: 'Cd::VersionSet', inverse_of: :rollouts, optional: false
    belongs_to :application, class_name: 'Cd::Application', inverse_of: :rollouts, optional: false
    belongs_to :application_flow_definition, class_name: 'Cd::ApplicationFlowDefinition', optional: true
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :rollout_environments, -> { ordered },
      class_name: 'Cd::RolloutEnvironment', inverse_of: :rollout
    has_many :rollout_transitions, -> { ordered },
      class_name: 'Cd::RolloutTransition', inverse_of: :rollout

    populate_sharding_key :organization_id, source: :version_set

    scope :in_organization, ->(organization) { where(organization_id: organization) }

    # workflow_ref is set when the rollout is kicked off (see
    # Cd::Rollouts::StartService), which also transitions it out of the initial
    # pending state, so it is required in every non-pending state.
    validates :workflow_ref, length: { maximum: 255 }
    validates :workflow_ref, presence: true, unless: :pending?

    # State machine defining the rollout lifecycle.
    # See https://gitlab.com/groups/gitlab-org/-/work_items/21247#rollout-states
    state_machine :state, initial: :pending do
      # -- Forward flow --
      event :start do
        transition pending: :in_progress
      end

      event :pause do
        transition in_progress: :paused
      end

      event :resume do
        transition paused: :in_progress
      end

      event :complete do
        transition in_progress: :completed
      end

      # Named `fail_rollout` to avoid conflict with Ruby's `Kernel#fail`.
      event :fail_rollout do
        transition in_progress: :failed
      end

      # -- Cancellation --
      event :cancel do
        transition in_progress: :cancelled
      end

      # -- Callbacks --
      before_transition any => :in_progress do |rollout|
        rollout.started_at ||= Time.current
      end

      before_transition any => TERMINAL_STATES do |rollout|
        rollout.finished_at = Time.current
      end
    end

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
