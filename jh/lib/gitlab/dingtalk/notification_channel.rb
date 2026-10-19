# frozen_string_literal: true

module Gitlab
  module Dingtalk
    module NotificationChannel
      def self.available?
        App.notifications_available?
      end

      def self.enqueue(user, attributes, notification_id:, **)
        return unless available? && ::JH::Users::DingtalkNotification.enabled_for?(user)

        recipient = Recipient.for_user(user)
        return unless recipient

        ::Dingtalk::SendNotificationWorker.perform_async(
          user.id, recipient, attributes, notification_id,
          { 'corp_id' => App.corp_id, 'app_id' => App.app_id, 'agent_id' => App.agent_id.to_s }
        )
      end
    end
  end
end
