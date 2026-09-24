# frozen_string_literal: true

module JH
  module NotificationService
    extend ::Gitlab::Utils::Override

    # Every notification in this service is dispatched through #mailer, so
    # standing in for it once is enough to mirror all of them to WeCom. The
    # alternative, hooking each event, would mean WeCom code to maintain
    # alongside every notification upstream adds.
    #
    # Recipients are whoever the mailer was about to write to, so WeCom follows
    # the notification settings, permissions and subscriptions already applied
    # here rather than forming a second opinion.
    override :mailer
    def mailer
      return super unless ::Gitlab::Wecom::App.notifications_available?

      ::Gitlab::Wecom::MailerFanout.new(super)
    end
  end
end
