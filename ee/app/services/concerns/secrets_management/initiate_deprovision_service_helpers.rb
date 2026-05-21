# frozen_string_literal: true

module SecretsManagement
  # Shared flow for SecretsManager InitiateDeprovision services. Validates the
  # secrets manager state, transitions to `deprovisioning`, persists a
  # maintenance task with snapshot IDs, enqueues the async worker, and returns
  # a scope-specific success payload.
  #
  # Including classes must implement:
  # - `not_found_message`              -- error when secrets_manager is nil
  # - `create_maintenance_task`        -- create + persist task with snapshot IDs
  # - `enqueue_deprovision_worker(task)` -- async worker enqueue
  # - `success_payload`                -- hash returned on success
  module InitiateDeprovisionServiceHelpers
    extend ActiveSupport::Concern
    include Helpers::ErrorResponseHelper

    def execute
      return ServiceResponse.error(message: not_found_message) unless secrets_manager
      return secrets_manager_inactive_response unless secrets_manager.active?

      # Transition the secrets manager state and insert the maintenance task
      # together. If only one succeeds we'd be stuck: SM in deprovisioning
      # with no task for the worker to run, or a task pointing at an SM
      # that's still active. Atomicity here means the row pair is always
      # consistent.
      #
      # perform_async is deliberately outside the transaction. If we
      # enqueued the worker first and the transaction then rolled back,
      # Sidekiq would pop a job pointing at a task that doesn't exist.
      task = ApplicationRecord.transaction do
        secrets_manager.initiate_deprovision!
        create_maintenance_task
      end

      enqueue_deprovision_worker(task)

      ServiceResponse.success(payload: success_payload)
    end

    private

    attr_reader :secrets_manager, :current_user

    def not_found_message
      raise NotImplementedError
    end

    def create_maintenance_task
      raise NotImplementedError
    end

    def enqueue_deprovision_worker(_task)
      raise NotImplementedError
    end

    def success_payload
      raise NotImplementedError
    end
  end
end
