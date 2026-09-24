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

        super
      end

      private

      def save_wecom_preference
        return unless ::Gitlab::Wecom::App.notifications_available?

        ::JH::Users::WecomNotification.set(
          current_user,
          ::Gitlab::Utils.to_boolean(params.dig(:user, :wecom_notifications_enabled)) || false
        )
      end
    end
  end
end
