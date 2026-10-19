# frozen_string_literal: true

module JH
  module Emails
    module Profile
      extend ::Gitlab::Utils::Override

      def notice_password_is_expiring_email(user, expiration_date)
        @user = user
        @expiration_date = expiration_date
        @token = @user.set_reset_password_token

        email = @user.notification_email_or_default
        mail_with_locale to: email, subject: s_('JH|Password is expiring soon') do |format|
          format.html { render layout: 'mailer/devise' }
          format.text
        end
      end

      # JiHu SaaS instances must never send GitLab.com PIPL migration emails,
      # even when enforce_pipl_compliance is on or a delivery job was already
      # enqueued. Skipping #mail makes Action Mailer return a NullMail, so
      # deliver_now/deliver_later perform no delivery at all.
      override :pipl_compliance_notification
      def pipl_compliance_notification(user, deadline); end
    end
  end
end
