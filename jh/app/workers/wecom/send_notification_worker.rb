# frozen_string_literal: true

module Wecom
  class SendNotificationWorker
    include ApplicationWorker

    data_consistency :delayed
    queue_namespace :wecom
    feature_category :integrations
    urgency :low
    worker_has_external_dependencies!

    idempotent!
    # A deduplication key left behind by a failed push would drop the retried channel job's push.
    deduplicate :none

    # Concurrency is not a request-rate limit: WeCom caps an app at 30 messages
    # per minute to the same member, and a daily quota by account size. This
    # only keeps the queue from stampeding; start conservative and raise it on
    # observed latency rather than guesswork.
    concurrency_limit -> { 10 }

    # WeCom gives no delivery guarantee, so a long retry tail buys nothing and
    # keeps re-sending a notification that is no longer timely.
    sidekiq_options retry: 3

    sidekiq_retries_exhausted do |job, exception|
      Gitlab::AppLogger.error(
        message: 'Giving up on a WeCom notification',
        Labkit::Fields::CLASS_NAME => name,
        wecom_event: job['args']&.first,
        Labkit::Fields::ERROR_TYPE => exception.class.name
      )
    end

    def perform(event, payload)
      return unless ::Gitlab::Wecom::App.notifications_available?

      user = ::User.find_by_id(payload['user_id'])
      return unless user&.active?
      return unless ::JH::Users::WecomNotification.enabled_for?(user)
      return unless ::Gitlab::Wecom::App.corp_id == payload['corp_id']

      recipient = ::JH::Users::WecomNotification.wecom_user_id_for(user)
      return unless recipient.present? && recipient == payload['recipient']

      ::Gitlab::I18n.with_user_locale(user) do
        deliver(recipient, payload['attributes'].symbolize_keys, event)
      end
    end

    private

    def deliver(wecom_user_id, attributes, event)
      result = ::Gitlab::Wecom::AppClient.new.send_card([wecom_user_id], card_for(attributes))

      return unless result.partial?

      # A member outside the app's visible range, or without a licence seat.
      # Retrying sends the same rejected recipient again.
      Gitlab::AppLogger.info(
        build_structured_payload_labkit(
          message: 'WeCom rejected a notification recipient',
          wecom_event: event
        )
      )
    rescue ::Gitlab::Wecom::AppClient::PermanentError => e
      Gitlab::AppLogger.error(
        build_structured_payload_labkit(
          message: 'WeCom refused a notification',
          wecom_event: event,
          Labkit::Fields::ERROR_MESSAGE => e.message
        )
      )
    end

    def card_for(attributes)
      ::Gitlab::Wecom::NotificationCard.new(**attributes).to_h
    end
  end
end
