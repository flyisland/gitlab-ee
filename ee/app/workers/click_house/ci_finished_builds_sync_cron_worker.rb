# frozen_string_literal: true

module ClickHouse
  class CiFinishedBuildsSyncCronWorker
    include ApplicationWorker

    version 2

    idempotent!
    queue_namespace :cronjob
    data_consistency :delayed
    feature_category :fleet_visibility
    tags :clickhouse
    loggable_arguments 1

    RECENT_WORKERS = 2
    BACKFILL_WORKERS = 3

    def perform(*args)
      return unless job_version == 2
      return unless ::ClickHouse::DataIngestion::CiFinishedBuildsSyncService.enabled?

      if backfill_in_progress?
        enqueue_split_workers
      elsif Gitlab.com? # rubocop:disable Gitlab/AvoidGitlabInstanceChecks -- temporary measure to drain remaining unprocessed sync events on .com
        enqueue_workers(5)
      else
        enqueue_workers(args.first || 1)
      end

      nil
    end

    private

    def backfill_in_progress?
      ::ClickHouse::MigrationSupport::CiFinishedBuildsConsistencyHelper.backfill_in_progress?
    end

    def enqueue_split_workers
      RECENT_WORKERS.times do |worker_index|
        CiFinishedBuildsSyncWorker.perform_async(worker_index, RECENT_WORKERS, 'recent')
      end

      BACKFILL_WORKERS.times do |worker_index|
        CiFinishedBuildsSyncWorker.perform_async(worker_index, BACKFILL_WORKERS, 'backfill')
      end
    end

    def enqueue_workers(total_workers)
      total_workers.times do |worker_index|
        CiFinishedBuildsSyncWorker.perform_async(worker_index, total_workers)
      end
    end
  end
end
