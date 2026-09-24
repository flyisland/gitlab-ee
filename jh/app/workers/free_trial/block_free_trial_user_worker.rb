# frozen_string_literal: true

module FreeTrial
  class BlockFreeTrialUserWorker
    include ApplicationWorker

    feature_category :not_owned

    sidekiq_options retry: 3

    idempotent!

    deduplicate :until_executing

    data_consistency :always

    queue_namespace :free_trial_management

    loggable_arguments 0, 1

    def perform(user_id)
      return unless Gitlab.com?

      BlockFreeTrialUserService.new(user_id).execute
    end
  end
end
