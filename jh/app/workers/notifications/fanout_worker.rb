# frozen_string_literal: true

module Notifications
  class FanoutWorker
    include ApplicationWorker

    data_consistency :delayed
    queue_namespace :notifications
    feature_category :integrations
    urgency :low
    worker_has_external_dependencies!
    idempotent!
    deduplicate :until_executed
    concurrency_limit -> { 10 }
    sidekiq_options retry: 3

    sidekiq_retries_exhausted do |_job, exception|
      ::Gitlab::AppLogger.error(
        message: 'Giving up on notification fanout',
        Labkit::Fields::CLASS_NAME => name,
        Labkit::Fields::ERROR_TYPE => exception.class.name
      )
    end

    def perform(event, serialized_args, serialized_kwargs, notification_id)
      return unless ::Gitlab::Notifications::MailerFanout.available?

      email = ::Gitlab::Notifications::Email.render(event, serialized_args, serialized_kwargs)
      user = email&.recipient
      return unless user&.active?

      # Extract mail metadata once so every notification channel reuses the same rendered message.
      attributes = email.attributes.deep_stringify_keys
      names = channel_names
      return if names.empty?

      # One bulk push queues every channel or none, so a retried fanout never queues a channel twice.
      # Each channel job then retries on its own without touching the others.
      ::Notifications::ChannelEnqueueWorker.bulk_perform_async_with_contexts(
        names,
        arguments_proc: ->(name) { [user.id, name, event, attributes, notification_id] },
        context_proc: ->(_name) { { user: user } }
      )
    end

    private

    def channel_names
      names = []
      ::Gitlab::Notifications::Channels.each do |name, channel|
        names << name.to_s if channel_available?(name, channel)
      end
      names
    end

    # A failed availability check is queued anyway so the channel job can retry it.
    def channel_available?(name, channel)
      channel.available?
    rescue StandardError => e
      ::Gitlab::AppLogger.error(
        build_structured_payload_labkit(
          message: 'Could not check a notification channel', channel: name.to_s,
          Labkit::Fields::ERROR_TYPE => e.class.name
        )
      )
      true
    end
  end
end
