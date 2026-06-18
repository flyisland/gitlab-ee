# frozen_string_literal: true

module Cd
  class Deployment < ApplicationRecord
    self.table_name = 'cd_deployments'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    TERMINAL_STATES = %i[healthy degraded failed cancelled].freeze

    belongs_to :rollout, class_name: 'Cd::Rollout', inverse_of: :deployments, optional: false
    belongs_to :version_set_entry, class_name: 'Cd::VersionSetEntry', inverse_of: :deployments, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false

    has_one :service, through: :version_set_entry
    has_one :version, through: :version_set_entry
    has_one :environment, through: :rollout

    populate_sharding_key :organization_id, source: :rollout

    validates :version_set_entry_id, uniqueness: { scope: :rollout_id,
                                                   message: ->(*) { _('already has a deployment in this rollout') } }
    validate :version_set_entry_belongs_to_rollout_version_set

    # State machine defining the deployment lifecycle.
    # See https://gitlab.com/groups/gitlab-org/-/work_items/21247#deployment-states-per-service-within-a-rollout
    state_machine :state, initial: :pending do
      # -- Forward flow --
      event :start_deploying do
        transition pending: :deploying
      end

      event :mark_healthy do
        transition deploying: :healthy
      end

      event :mark_degraded do
        transition deploying: :degraded
      end

      # Named `fail_deployment` to avoid conflict with Ruby's `Kernel#fail`.
      event :fail_deployment do
        transition deploying: :failed
      end

      # -- Cancellation --
      event :cancel do
        transition deploying: :cancelled
      end

      # -- Callbacks --
      before_transition any => :deploying do |deployment|
        deployment.started_at ||= Time.current
      end

      before_transition any => TERMINAL_STATES do |deployment|
        deployment.finished_at = Time.current
      end
    end

    enum :state, {
      pending: 0,
      deploying: 1,
      healthy: 2,
      degraded: 3,
      failed: 4,
      cancelled: 5
    }

    private

    def version_set_entry_belongs_to_rollout_version_set
      return if version_set_entry.blank? || rollout.blank?
      return if version_set_entry.version_set_id == rollout.version_set_id

      errors.add(:version_set_entry, _('must belong to the rollout\'s version set'))
    end
  end
end
