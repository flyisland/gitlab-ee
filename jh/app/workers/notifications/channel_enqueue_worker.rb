# frozen_string_literal: true

module Notifications
  class ChannelEnqueueWorker
    include ApplicationWorker

    data_consistency :delayed
    queue_namespace :notifications
    feature_category :integrations
    urgency :low
    idempotent!
    # A deduplication key left behind by a failed push would silently drop the retried job.
    deduplicate :none
    # A limit could defer part of a bulk push, and a retried fanout would then queue those channels twice.
    concurrency_limit -> { 0 }
    sidekiq_options retry: 3

    sidekiq_retries_exhausted do |job, exception|
      ::Gitlab::AppLogger.error(
        message: 'Giving up on queueing a notification channel',
        Labkit::Fields::CLASS_NAME => name,
        channel: job['args']&.second,
        Labkit::Fields::ERROR_TYPE => exception.class.name
      )
    end

    def perform(user_id, channel_name, event, attributes, notification_id)
      channel = ::Gitlab::Notifications::Channels.fetch(channel_name)
      return unless channel&.available?

      user = ::User.find_by_id(user_id)
      return unless user&.active?

      channel.enqueue(user, attributes, event: event, notification_id: notification_id)
    end
  end
end
