# frozen_string_literal: true

module Feishu
  class SendNotificationWorker
    include ApplicationWorker

    data_consistency :delayed
    queue_namespace :feishu
    feature_category :integrations
    urgency :low
    worker_has_external_dependencies!
    idempotent!
    # A deduplication key left behind by a failed push would drop the retried channel job's push.
    deduplicate :none
    concurrency_limit -> { 10 }
    sidekiq_options retry: 3

    # Feishu ignores a repeated message UUID for one hour after the first request. Retries stop before then,
    # leaving a margin for request time and clock skew, because a lost success response could otherwise repeat.
    SEND_DEADLINE = 55.minutes
    FIRST_ATTEMPT_TTL = 1.day

    # Returning nil keeps Sidekiq's default backoff when Feishu gives no usable delay.
    sidekiq_retry_in do |_count, exception|
      exception.retry_after if exception.is_a?(::Gitlab::Feishu::AppResponse::RateLimited)
    end

    sidekiq_retries_exhausted do |_job, exception|
      ::Gitlab::AppLogger.error(
        message: 'Giving up on a Feishu notification',
        Labkit::Fields::CLASS_NAME => name,
        Labkit::Fields::ERROR_TYPE => exception.class.name
      )
    end

    def perform(user_id, extern_uid, attributes, notification_id)
      return unless ::Gitlab::Feishu::App.notifications_available?

      user = ::User.find_by_id(user_id)
      return unless ::JH::Users::FeishuNotification.enabled_for?(user)
      return unless ::JH::Users::FeishuNotification.extern_uid_for(user) == extern_uid

      open_id = ::JH::Users::FeishuNotification.open_id_for(extern_uid)
      return if open_id.nil?

      icon_key = ::Gitlab::Feishu::NotificationIcon.image_key
      card = ::Gitlab::I18n.with_user_locale(user) do
        ::Gitlab::Feishu::NotificationCard.new(**attributes.symbolize_keys, icon_key: icon_key).to_h
      end
      return log_expired_delivery unless before_send_deadline?(notification_id)

      ::Gitlab::Feishu::AppClient.new.send_card(open_id, card, uuid: notification_id)
    rescue ::Gitlab::Feishu::AppClient::PermanentError => e
      ::Gitlab::AppLogger.error(
        build_structured_payload_labkit(
          message: 'Feishu refused a notification',
          Labkit::Fields::ERROR_MESSAGE => e.message
        )
      )
    end

    private

    def before_send_deadline?(notification_id)
      key = "feishu:notification:#{notification_id}:first_attempt_at"
      now = Time.current.to_i
      first_attempt_at = ::Gitlab::Redis::SharedState.with do |redis|
        redis.set(key, now, nx: true, ex: FIRST_ATTEMPT_TTL.to_i)
        redis.get(key)
      end

      first_attempt_at.present? && now - first_attempt_at.to_i < SEND_DEADLINE.to_i
    end

    def log_expired_delivery
      ::Gitlab::AppLogger.warn(
        build_structured_payload_labkit(message: 'Dropping a Feishu notification past its UUID deduplication window')
      )
    end
  end
end
