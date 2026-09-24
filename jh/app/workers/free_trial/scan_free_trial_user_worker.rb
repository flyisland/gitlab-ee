# frozen_string_literal: true

module FreeTrial
  class ScanFreeTrialUserWorker
    include ApplicationWorker

    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext -- jh cron job

    data_consistency :always

    feature_category :not_owned

    sidekiq_options retry: false

    idempotent!

    deduplicate :until_executing

    worker_has_external_dependencies!

    worker_resource_boundary :memory

    METRIC_SUCCESS = 1
    METRIC_FAILED = 0

    def perform(dry_run = false)
      return unless Gitlab.com?

      metric = ::Gitlab::Metrics.gauge(:free_trial_scan_worker_status, 'status of free trial user worker',
        { version: Gitlab.version_info.to_s })
      begin
        ScanFreeTrialUserService.new(dry_run: dry_run).execute
        metric.set({}, METRIC_SUCCESS)
      rescue StandardError => e
        metric.set({}, METRIC_FAILED)
        raise e
      end
    end
  end
end
