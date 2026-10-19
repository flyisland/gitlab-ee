# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Stage
      class EnableContinuousSyncWorker # rubocop:disable Scalability/IdempotentWorker -- every run enqueues FinishImportWorker
        include ApplicationWorker

        data_consistency :sticky

        include StageMethods

        # Safe to resume: the handoff is skipped once the row has left provisioning.
        resumes_work_when_interrupted!

        # Replaces the StageMethods block: a failure here must not fail an import whose data is already copied.
        sidekiq_retries_exhausted do |msg, e|
          finish_without_continuous_sync(msg['args'][0], e)
        end

        def self.finish_without_continuous_sync(project_id, exception)
          Gitlab::Import::ImportFailureService.track(
            project_id: project_id,
            exception: exception,
            error_source: name,
            fail_import: false
          )

          FinishImportWorker.perform_async(project_id)
        end

        def import(_client, project)
          sync_repository = project.import_sync_repository

          if sync_repository.nil?
            info(project.id, message: 'no sync repository found, finishing without continuous sync')
          elsif sync_repository.provisioning?
            sync_repository.provider_canonical!
          else
            info(
              project.id,
              message: "sync repository is #{sync_repository.authority_state}, finishing without continuous sync"
            )
          end

          # Register the GitHub webhook here once WebhookManagementService lands.

          FinishImportWorker.perform_async(project.id)
        end
      end
    end
  end
end
