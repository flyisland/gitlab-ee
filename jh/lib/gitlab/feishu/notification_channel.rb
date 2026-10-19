# frozen_string_literal: true

module Gitlab
  module Feishu
    module NotificationChannel
      def self.available?
        App.notifications_available?
      end

      def self.enqueue(user, attributes, notification_id:, **_options)
        return unless ::JH::Users::FeishuNotification.enabled_for?(user)

        extern_uid = ::JH::Users::FeishuNotification.extern_uid_for(user)
        return unless ::JH::Users::FeishuNotification.open_id_for(extern_uid)

        ::Feishu::SendNotificationWorker.perform_async(user.id, extern_uid, attributes, notification_id)
      end
    end
  end
end
