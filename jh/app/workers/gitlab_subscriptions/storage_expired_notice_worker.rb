# frozen_string_literal: true

module GitlabSubscriptions
  class StorageExpiredNoticeWorker
    include ApplicationWorker
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    feature_category :not_owned

    idempotent!

    deduplicate :until_executing

    data_consistency :always

    loggable_arguments 0, 1

    def perform
      return unless Gitlab.com?

      GitlabSubscriptions::ExpiredStorageNotice.execute
    end
  end
end
