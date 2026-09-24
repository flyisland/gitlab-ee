# frozen_string_literal: true

module FreeTrial
  class RemoveFreeTrialUserWorker
    include ApplicationWorker

    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext -- jh cron job

    data_consistency :always

    feature_category :not_owned

    sidekiq_options retry: false

    idempotent!

    deduplicate :until_executing

    worker_resource_boundary :memory

    FREE_TRIAL_START_DATE = Date.parse(ENV.fetch('JH_FREE_TRIAL_START_DATE', '2024-01-02'))

    def perform(dry_run = false)
      return unless Gitlab.com?
      return if !dry_run && before_remove_date?

      RemoveFreeTrialUserService.new(dry_run: dry_run).execute
    end

    private

    def before_remove_date?
      Date.current.before?(FREE_TRIAL_START_DATE + RemoveFreeTrialUserService::JH_FREE_TRIAL_DATA_KEEP_DURATION.years)
    end
  end
end
