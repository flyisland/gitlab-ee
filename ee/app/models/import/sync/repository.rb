# frozen_string_literal: true

module Import
  module Sync
    # Associates one stable GitHub repository with one GitLab project, owning the
    # provider connection, provider authority, and the application-generation fence.
    class Repository < ApplicationRecord
      self.table_name = 'import_sync_repositories'

      # Both predicates below cover the same authority states today, but they express
      # distinct concepts (write-blocking vs. provider-identity ownership) that may
      # diverge later, so this is intentionally not a single shared constant.
      READ_ONLY_AUTHORITY_STATES = %w[
        provisioning
        provider_canonical
        disconnected
        cutting_over
        cutover_failed
      ].freeze
      PROVIDER_BOUND_AUTHORITY_STATES = %w[
        provisioning
        provider_canonical
        disconnected
        cutting_over
        cutover_failed
      ].freeze

      # GitHub OAuth has no revocation webhook, so a revoked token only shows up as
      # repeated 401s. This tolerates a handful of blips before treating it as revoked.
      MAX_CONSECUTIVE_AUTH_FAILURES = 5

      NotDisconnectedError = Class.new(StandardError)

      scope :provider_bound, -> { where(authority_state: PROVIDER_BOUND_AUTHORITY_STATES) }

      belongs_to :project, inverse_of: :import_sync_repository, optional: false
      belongs_to :connected_by_user, class_name: 'User', optional: true

      has_many :sync_states,
        class_name: 'Import::Sync::RepositoryState',
        foreign_key: :import_sync_repository_id,
        inverse_of: :repository
      has_many :external_objects,
        class_name: 'Import::Sync::ExternalObject',
        foreign_key: :import_sync_repository_id,
        inverse_of: :repository

      enum :provider, { github: 0 }, prefix: true
      enum :authority_state, {
        provisioning: 0,
        bootstrap_canceled: 1,
        provider_canonical: 2,
        disconnected: 3,
        cutting_over: 4,
        cutover_failed: 5,
        gitlab_canonical: 6
      }
      enum :disconnect_reason, {
        installation_suspended: 0,
        installation_removed: 1,
        repository_access_removed: 2,
        github_app_permissions_required: 3,
        token_revoked: 4,
        insufficient_scope: 5,
        user_deauthorized: 6
      }, prefix: :disconnected_because
      enum :restore_authority_state, {
        provisioning: 0,
        provider_canonical: 2
      }, prefix: :restore_to

      prevent_from_serialization :webhook_secret
      encrypts :webhook_secret

      validates :provider_account_xid,
        numericality: { only_integer: true, greater_than: 0 }
      # nil for OAuth-connected repositories; filled in when upgraded to a GitHub App installation.
      validates :provider_installation_xid,
        numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      validates :provider_account_login, presence: true, length: { maximum: 255 }
      validates :provider_repository_xid,
        numericality: { only_integer: true, greater_than: 0 },
        if: :provider_bound?
      validates :provider_repository_node_id, :provider_full_name, presence: true, length: { maximum: 255 }
      validates :provider_default_branch, length: { maximum: 255 }, allow_nil: true
      validates :provider_webhook_xid, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      validates :webhook_secret, length: { maximum: 510 }, allow_nil: true
      validates :project_id, uniqueness: true
      validates :application_generation, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :consecutive_auth_failures, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :disconnect_reason, presence: true, if: :disconnected?
      validates :restore_authority_state, presence: true, if: :disconnected?
      validates :disconnect_reason, :restore_authority_state, absence: true, unless: :disconnected?

      # Returns whether local mutations must remain blocked for this authority
      # state. Installation suspension or revocation never makes a project writable.
      # This predicate is deterministic and has no side effects.
      def read_only?
        READ_ONLY_AUTHORITY_STATES.include?(authority_state)
      end

      # Returns whether this row still owns the installation's provider identity.
      # Canceled imports and completed cutovers remain as history but no longer
      # prevent the existing importer UI from starting a new checked import.
      def provider_bound?
        PROVIDER_BOUND_AUTHORITY_STATES.include?(authority_state)
      end

      # Compares a job's captured fence with the repository's durable generation.
      # Invalid or missing values return false rather than raising, and no state is
      # changed.
      def application_generation_current?(captured_generation)
        captured_generation.is_a?(Integer) && application_generation == captured_generation
      end

      # Records one provider API call failing with an authentication error.
      # Disconnects the repository once MAX_CONSECUTIVE_AUTH_FAILURES is reached
      # in a row; a single failure alone does not disconnect it.
      #
      # Takes a row lock so concurrent callers can't both read a stale
      # pre-increment count and under-count the failures between them.
      #
      # @param reason [Symbol] a +disconnect_reason+ enum value to record if this
      #   failure trips the disconnect
      # @return [void]
      def record_auth_failure!(reason: :token_revoked)
        with_lock do
          if consecutive_auth_failures + 1 >= MAX_CONSECUTIVE_AUTH_FAILURES
            disconnect!(reason)
          else
            increment!(:consecutive_auth_failures)
          end
        end
      end

      # Clears the consecutive failure count after a successful provider API call.
      #
      # @return [void]
      def clear_auth_failures!
        update!(consecutive_auth_failures: 0) if consecutive_auth_failures != 0
      end

      # Moves the repository into the disconnected, read-only authority state,
      # recording why and which state to return to once the user reconnects.
      #
      # @param reason [Symbol] a +disconnect_reason+ enum value
      # @param restore_to [Symbol] a +restore_authority_state+ enum value
      # @return [void]
      def disconnect!(reason, restore_to: :provider_canonical)
        update!(
          authority_state: :disconnected,
          disconnect_reason: reason,
          restore_authority_state: restore_to,
          consecutive_auth_failures: 0
        )
      end

      # Reverses #disconnect!, returning the repository to the authority state it
      # had before disconnecting.
      #
      # @return [void]
      def restore!
        raise NotDisconnectedError, 'repository is not disconnected' unless disconnected?

        update!(authority_state: restore_authority_state, disconnect_reason: nil, restore_authority_state: nil)
      end

      # Call inside a transaction: the row locks are released when it ends.
      def sync_states_for_update(domains)
        states = locked_sync_states(domains)
        return states if states.size == domains.size

        ensure_sync_states
        locked_sync_states(domains)
      end

      private

      def locked_sync_states(domains)
        sync_states.where(domain: domains).lock.index_by(&:domain)
      end

      # Rows start out needing their first sync. Existing rows are left alone, and
      # concurrent jobs can run this at the same time.
      def ensure_sync_states
        rows = RepositoryState.domains.each_key.map do |domain|
          {
            import_sync_repository_id: id,
            project_id: project_id,
            domain: domain,
            state: :pending,
            desired_generation: 1,
            synced_generation: 0
          }
        end

        RepositoryState.insert_all(rows, unique_by: :idx_import_sync_repository_states_on_repository_and_domain)
      end
    end
  end
end
