# frozen_string_literal: true

module PasswordExpiration
  class SendNotificationEmailWorker
    include ApplicationWorker

    # rubocop:disable Scalability/CronWorkerContext
    include CronjobQueue

    # rubocop:enable Scalability/CronWorkerContext

    feature_category :user_profile

    def perform
      SendNotificationEmailService.new.execute
    end
  end
end
