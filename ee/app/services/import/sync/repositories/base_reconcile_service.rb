# frozen_string_literal: true

module Import
  module Sync
    module Repositories
      # Shared lease handling, application fence and failure recording for the per-domain reconcile services.
      class BaseReconcileService
        def initialize(repository, application_generation:, allow_cutover: false, now: -> { Time.current })
          @repository = repository
          @project = repository.project
          @application_generation = application_generation
          @allow_cutover = allow_cutover
          @now = now
        end

        def execute(lease_context: nil)
          if lease_context
            lease_context.verify_repository!(repository.id)
            return execute_with_failure_recording(lease_context)
          end

          ApplicationLease.new(repository.id).execute { |context| execute_with_failure_recording(context) }
        end

        private

        attr_reader :repository, :project, :application_generation, :allow_cutover, :now

        def reconcile_under_lease(_lease_context)
          raise NotImplementedError
        end

        def record_failure!
          raise NotImplementedError
        end

        def execute_with_failure_recording(lease_context)
          reconcile_under_lease(lease_context)
        rescue ApplicationLease::LostLeaseError
          raise
        rescue StandardError
          record_failure
          raise
        end

        def record_failure
          record_failure!
        rescue StandardError => error
          # The original pass error must be what propagates.
          ::Gitlab::ErrorTracking.track_exception(error, import_sync_repository_id: repository.id)
        end

        def verify_application_fence!(lease_context)
          lease_context.verify!

          repository.with_lock do
            next if application_current?

            raise Errors::StaleApplicationError, 'Import sync repository application generation changed'
          end
        end

        def application_current?
          provider_application_allowed? && repository.application_generation_current?(application_generation)
        end

        def provider_application_allowed?
          repository.provider_canonical? || (allow_cutover && repository.cutting_over?)
        end

        # Health fields only get fixed messages; cursor contents and provider error details must never reach them.
        def mark_failed!(state)
          if provider_application_allowed?
            state.state = :degraded
            state.last_error_code = self.class::FAILURE_CODE
            state.last_error_message = self.class::FAILURE_MESSAGE
          else
            state.state = :paused
            state.last_error_code = 'github_updates_inactive'
            state.last_error_message = 'GitHub updates are not active'
          end

          state.save!

          ::Gitlab::GithubImport::Logger.warn(
            message: self.class::FAILURE_LOG_MESSAGE,
            import_sync_repository_id: repository.id,
            Labkit::Fields::GL_PROJECT_ID => project.id,
            domain: state.domain,
            last_error_code: state.last_error_code,
            health_state: state.state
          )
        end

        def authentication
          @authentication ||= Authentication.for(repository)
        end

        def provider_client
          @provider_client ||= authentication.client(parallel: true)
        end

        def result(applied_domains, follow_up)
          { applied_domains: applied_domains, follow_up: follow_up }
        end
      end
    end
  end
end
