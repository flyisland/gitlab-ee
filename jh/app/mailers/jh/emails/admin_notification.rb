# frozen_string_literal: true

module JH
  module Emails
    module AdminNotification
      def free_trial_remind_notification(user_id, trial_end_date)
        @user = ::User.find user_id
        @trial_end_date = trial_end_date

        subject_text = ::Gitlab::I18n.with_user_locale(@user) { s_("JH|FreeTrial|Your free trial will end soon") }
        mail_with_locale(
          to: @user.email,
          subject: subject(format(subject_text))
        ) do |format|
          format.html { render layout: 'mailer' }
        end
      end

      def free_trial_ends_notification(user_id)
        @user = ::User.find user_id

        subject_text = ::Gitlab::I18n.with_user_locale(@user) { s_("JH|FreeTrial|Your free trial ends") }
        mail_with_locale(
          to: @user.email,
          subject: subject(format(subject_text))
        ) do |format|
          format.html { render layout: 'mailer' }
        end
      end

      def storage_expiry_notification(user_id, namespace_id, days_until_expiry, storage_expiry_date)
        @user = ::User.find user_id
        @namespace = ::Namespace.find(namespace_id)
        @days_until_expiry = days_until_expiry
        @storage_expiry_date = storage_expiry_date
        subject_text = ::Gitlab::I18n.with_user_locale(@user) do
          s_("JH|The additional storage you purchased on JihuLab.com is about to expire.")
        end
        mail_with_locale(
          to: @user.email,
          subject: subject(format(subject_text))
        ) do |format|
          format.html { render layout: 'mailer' }
        end
      end
    end
  end
end
