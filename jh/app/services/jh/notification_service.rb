# frozen_string_literal: true

module JH
  module NotificationService
    extend ::Gitlab::Utils::Override

    override :mailer
    def mailer
      return super unless ::Gitlab::Notifications::MailerFanout.available?

      ::Gitlab::Notifications::MailerFanout.new(super)
    end
  end
end
