# frozen_string_literal: true

module Dingtalk
  class SendNotificationWorker
    include ApplicationWorker

    data_consistency :delayed
    queue_namespace :dingtalk
    feature_category :integrations
    urgency :low
    worker_has_external_dependencies!
    idempotent!
    # A deduplication key left behind by a failed push would drop the retried channel job's push.
    deduplicate :none
    concurrency_limit -> { 10 }
    sidekiq_options retry: 3

    sidekiq_retries_exhausted do |_job, exception|
      ::Gitlab::AppLogger.error(
        message: 'Giving up on a DingTalk notification',
        Labkit::Fields::CLASS_NAME => name,
        Labkit::Fields::ERROR_TYPE => exception.class.name
      )
    end

    def perform(user_id, recipient, attributes, notification_id, app_scope)
      return unless ::Gitlab::Dingtalk::App.notifications_available? && current_scope == app_scope

      user = ::User.find_by_id(user_id)
      return unless ::JH::Users::DingtalkNotification.enabled_for?(user)
      return unless ::Gitlab::Dingtalk::Recipient.for_user(user) == recipient

      key = "dingtalk:notification:#{notification_id}:#{user_id}"
      return if Rails.cache.read(key)

      ::Gitlab::I18n.with_user_locale(user) do
        card = ::Gitlab::Dingtalk::NotificationCard.new(**attributes.symbolize_keys).to_h
        ::Gitlab::Dingtalk::AppClient.new.send_card(recipient, card)
      end
      Rails.cache.write(key, true, expires_in: 1.day)
    rescue ::Gitlab::Dingtalk::AppClient::PermanentError => e
      ::Gitlab::AppLogger.info(
        build_structured_payload_labkit(
          message: 'DingTalk refused a notification',
          Labkit::Fields::ERROR_TYPE => e.class.name
        )
      )
    end

    private

    def current_scope
      app = ::Gitlab::Dingtalk::App
      { 'corp_id' => app.corp_id, 'app_id' => app.app_id, 'agent_id' => app.agent_id.to_s }
    end
  end
end
