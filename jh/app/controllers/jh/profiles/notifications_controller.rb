# frozen_string_literal: true

module JH
  module Profiles
    module NotificationsController
      extend ::Gitlab::Utils::Override

      # The opt-in is a user custom attribute, so Users::UpdateService cannot
      # carry it and it is saved on its own. The two writes are independent:
      # a rejected notification_email still stores the WeCom choice.
      #
      # The gate is applied here, not only in the view, so a crafted request
      # cannot switch on a channel the instance does not offer.
      override :update
      def update
        save_wecom_preference
        save_feishu_preference
        save_dingtalk_preference

        super
      end

      private

      def save_feishu_preference
        return unless ::Gitlab::Feishu::App.notifications_available?

        preference = params.permit(user: [:feishu_notifications_enabled]).fetch(:user, {})
        return unless preference.key?(:feishu_notifications_enabled)

        ::JH::Users::FeishuNotification.set(
          current_user, ::Gitlab::Utils.to_boolean(preference[:feishu_notifications_enabled]) || false
        )
      end

      def save_dingtalk_preference
        return unless ::Gitlab::Dingtalk::App.notifications_available?

        preference = params.require(:user).permit(:dingtalk_notifications_enabled)
        return unless preference.key?(:dingtalk_notifications_enabled)

        ::JH::Users::DingtalkNotification.set(
          current_user, ::Gitlab::Utils.to_boolean(preference[:dingtalk_notifications_enabled]) || false
        )
      end

      def save_wecom_preference
        return unless ::Gitlab::Wecom::App.notifications_available?

        preference = params.permit(user: [:wecom_notifications_enabled]).fetch(:user, {})
        return unless preference.key?(:wecom_notifications_enabled)

        ::JH::Users::WecomNotification.set(
          current_user, ::Gitlab::Utils.to_boolean(preference[:wecom_notifications_enabled]) || false
        )
      end
    end
  end
end
