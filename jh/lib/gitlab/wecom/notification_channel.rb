# frozen_string_literal: true

module Gitlab
  module Wecom
    module NotificationChannel
      def self.available?
        App.notifications_available?
      end

      def self.enqueue(user, attributes, event:, notification_id:)
        return unless ::JH::Users::WecomNotification.enabled_for?(user)

        recipient = ::JH::Users::WecomNotification.wecom_user_id_for(user)
        return if recipient.blank?

        ::Wecom::SendNotificationWorker.perform_async(event, {
          'user_id' => user.id, 'recipient' => recipient, 'corp_id' => App.corp_id,
          'attributes' => attributes, 'notification_id' => notification_id
        })
      end
    end
  end
end
