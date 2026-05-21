# frozen_string_literal: true

module SecretsManagement
  # Shared async-deprovision logic for both project and group secrets
  # managers. This is what the worker calls.
  #
  # The OpenBao paths we need to tear down (organization, root namespace,
  # the entity itself) are read off the maintenance task, NOT off the
  # secrets manager record. That's deliberate: by the time this runs, the
  # parent project or group may already be destroyed. The maintenance
  # task carries a snapshot of the IDs we need, taken at the moment the
  # destroy/transfer hook fired, so paths stay correct regardless of
  # what's happened to the live records in between.
  #
  # When the cleanup finishes, the secrets manager row gets destroyed.
  # That's important because we use the survival of that row as our
  # orphan signal: if the cleanup never finished, the row stays behind
  # with `project_id = NULL` (or `group_id = NULL`) for the reaper
  # (gitlab-org/gitlab#600120) to pick up later.
  #
  # End state when everything succeeds:
  #   - OpenBao namespaces removed (entity -> root group -> org)
  #   - Secrets manager row destroyed
  #   - Maintenance task destroyed
  #
  # Subclasses (project / group versions) must implement:
  #   - lease_key_prefix     scope-specific lease key namespace
  #   - entity_path          the level-3 path (project_<id> or group_<id>)
  #   - find_secrets_manager best-effort lookup; may return nil
  #   - payload_key          key for the ServiceResponse payload
  class BaseDeprovisionService
    include Gitlab::ExclusiveLeaseHelpers
    include Helpers::ExclusiveLeaseHelper
    include Helpers::ErrorResponseHelper

    LEASE_TIMEOUT = 120.seconds.to_i
    MAX_NAMESPACE_STATUS_POLL_ATTEMPTS = 20
    POLL_SLEEP_INTERVAL = 0.1.seconds

    attr_reader :maintenance_task, :current_user

    def initialize(maintenance_task, current_user)
      @maintenance_task = maintenance_task
      @current_user = current_user
    end

    def execute
      in_lock(lease_key, ttl: LEASE_TIMEOUT, retries: 0) do
        execute_deprovision
      end
    rescue FailedToObtainLockError
      obtain_lease_failure_response
    end

    private

    delegate :org_path, :root_namespace_path, to: :maintenance_task

    def lease_key
      "#{lease_key_prefix}:#{entity_path}"
    end

    # Subclasses override these.
    def lease_key_prefix
      raise NotImplementedError
    end

    def entity_path
      raise NotImplementedError
    end

    def find_secrets_manager
      raise NotImplementedError
    end

    def payload_key
      raise NotImplementedError
    end

    # Async deprovision may run after the project/group is gone; use the
    # system JWT so we don't depend on a live parent record.
    def base_secrets_manager_client
      @base_secrets_manager_client ||= begin
        jwt = GlobalSecretsManagerJwt.new(current_user: current_user).encoded
        SecretsManagerClient.new(jwt: jwt)
      end
    end

    def org_secrets_manager_client
      @org_secrets_manager_client ||=
        base_secrets_manager_client.with_namespace(org_path)
    end

    def namespace_secrets_manager_client
      @namespace_secrets_manager_client ||=
        base_secrets_manager_client.with_namespace([org_path, root_namespace_path].join('/'))
    end

    def execute_deprovision
      disable_entity_namespace
      disable_root_namespace
      disable_org_namespace

      # The DB cleanup runs in a single transaction so "deprovision is
      # complete" is an atomic fact at the row level. If either delete
      # fails, both roll back and the next worker run (or the reaper)
      # picks up the consistent state.
      #
      # Order inside the transaction: task first, then secrets manager.
      # That keeps the flow FK-policy-independent. See
      # gitlab-org/gitlab#600120 (orphan reaper) for the broader policy:
      # no `ON DELETE CASCADE` for SM table FKs. The reaper does manual
      # cleanup on the recovery path, and the happy path here mirrors
      # that order.
      ApplicationRecord.transaction do
        delete_maintenance_task
        delete_secrets_manager
      end

      ServiceResponse.success(payload: { payload_key => maintenance_task })
    end

    # Deleting the entity namespace also removes all data under it
    # (auth engines, secrets engine, policies). Namespaces can only be
    # disabled when empty of children; the entity namespace has none.
    def disable_entity_namespace
      MAX_NAMESPACE_STATUS_POLL_ATTEMPTS.times do |n|
        result = namespace_secrets_manager_client.disable_namespace(entity_path)
        if result.key?("data") && !result["data"].nil? &&
            result["data"].key?("status") && !result["data"]["status"].nil? &&
            result["data"]["status"] == "in-progress"
          sleep POLL_SLEEP_INTERVAL * n
          next
        end

        break
      end
    rescue SecretsManagement::SecretsManagerClient::ApiError => e
      # Namespace was never created (e.g. legacy record); continue cleanup.
      raise e unless e.message.include? 'route entry not found'
    end

    # Lazily delete the root group (level 2) namespace. The level-2 and
    # level-1 parents are shared by every SM under them, so each worker
    # speculatively tries to delete them and tolerates two outcomes:
    #
    #   - "containing child namespaces": at least one sibling SM is
    #     still alive under this parent, so we leave the cleanup for
    #     whichever sibling runs last.
    #
    #   - "route entry not found": another worker beat us to the
    #     delete. Concretely, picture a group transfer that initiates
    #     deprovision for N SMs at once. Worker A finishes its entity
    #     teardown first, finds the parent empty, deletes it. Worker B
    #     finishes its entity teardown a moment later, also tries to
    #     delete the parent, but OpenBao reports the namespace is gone
    #     because A already deleted it. From B's point of view that is
    #     not an error: the desired end state is "parent removed", and
    #     it already happened.
    #
    # Failing to rescue either of these would leak the exception up to
    # the worker, mark the maintenance task as failed, and leave it
    # stuck on the retry path. The cron retry worker would just hit the
    # same outcome on every run, never letting the task drain.
    def disable_root_namespace
      org_secrets_manager_client.disable_namespace(root_namespace_path)
    rescue SecretsManagement::SecretsManagerClient::ApiError => e
      raise e unless lazy_cleanup_expected_error?(e)
    end

    # Lazily delete the organization (level 1) namespace. Same two
    # expected outcomes as `disable_root_namespace`.
    def disable_org_namespace
      base_secrets_manager_client.disable_namespace(org_path)
    rescue SecretsManagement::SecretsManagerClient::ApiError => e
      raise e unless lazy_cleanup_expected_error?(e)
    end

    def lazy_cleanup_expected_error?(error)
      error.message.include?('containing child namespaces') ||
        error.message.include?('route entry not found')
    end

    # We destroy the secrets manager row at the end of a successful run.
    # That's what keeps the orphan query (`where(parent_id: nil)`)
    # honest: a row only stays around if cleanup didn't finish. Safe-nav
    # covers the rare case where the row has already been removed (a
    # previous partial run, or the reaper got here first).
    def delete_secrets_manager
      find_secrets_manager&.destroy!
    end

    # Destroy the maintenance task explicitly so the deprovision flow
    # doesn't depend on any FK CASCADE behavior between the task and
    # the secrets manager. That keeps us aligned with the no-CASCADE
    # policy described in gitlab-org/gitlab#600120.
    def delete_maintenance_task
      maintenance_task.destroy!
    end
  end
end
