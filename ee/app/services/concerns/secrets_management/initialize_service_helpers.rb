# frozen_string_literal: true

module SecretsManagement
  # Shared flow for SecretsManager Initialize services. Runs the SM-exists
  # guard, runs any scope-specific guards, then creates the SM record and
  # the `:provision` maintenance task in one transaction, enqueues the
  # async worker, and returns a scope-specific success payload.
  #
  # Anchoring the provision flow on a maintenance task gives the worker
  # the same crash-recovery guarantees the deprovision flow already has:
  # if the async worker dies, the task is left stale and the cron worker
  # retries it. The provision service is designed to be idempotent.
  #
  # The SM-exists guard runs in `execute` itself, not in the overridable
  # `ensure_secrets_manager_allowed_on_resource` hook, so subclasses
  # cannot accidentally skip it when they override that hook.
  #
  # Including classes must implement:
  # - `resource`                        -- project or group record
  # - `create_secrets_manager`          -- create + persist the SM record
  # - `create_maintenance_task(sm)`     -- create + persist the provision task
  # - `enqueue_provision_worker(task)`  -- async worker enqueue
  #
  # Including classes may override:
  # - `ensure_secrets_manager_allowed_on_resource` for additional guards
  module InitializeServiceHelpers
    extend ActiveSupport::Concern

    delegate :secrets_manager, to: :resource

    def execute
      return secrets_manager_exists_response if secrets_manager.present?

      result = ensure_secrets_manager_allowed_on_resource
      return result if result.error?

      secrets_manager_record = nil

      # SM creation and maintenance task creation must commit together. If
      # only one succeeds we'd be stuck: an SM with no task (no retry on
      # worker death) or a task pointing at no SM. Enqueue is outside the
      # transaction so a rollback never leaves a Sidekiq job pointing at
      # a task that doesn't exist.
      task = ApplicationRecord.transaction do
        secrets_manager_record = create_secrets_manager
        create_maintenance_task(secrets_manager_record)
      end

      enqueue_provision_worker(task)

      ServiceResponse.success(payload: success_payload(secrets_manager_record))
    end

    private

    def resource_type
      resource.model_name.singular
    end

    def secrets_manager_exists_response
      ServiceResponse.error(message: "Secrets manager already initialized for the #{resource_type}.")
    end

    def ensure_secrets_manager_allowed_on_resource
      ServiceResponse.success
    end

    def success_payload(secrets_manager)
      { "#{resource_type}_secrets_manager": secrets_manager }
    end

    def resource
      raise NotImplementedError
    end

    def create_secrets_manager
      raise NotImplementedError
    end

    def create_maintenance_task(_secrets_manager)
      raise NotImplementedError
    end

    def enqueue_provision_worker(_task)
      raise NotImplementedError
    end
  end
end
