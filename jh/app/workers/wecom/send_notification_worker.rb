# frozen_string_literal: true

module Wecom
  class SendNotificationWorker
    include ApplicationWorker

    data_consistency :delayed
    queue_namespace :wecom
    feature_category :integrations
    urgency :low
    worker_has_external_dependencies!

    idempotent!
    deduplicate :until_executed

    # Concurrency is not a request-rate limit: WeCom caps an app at 30 messages
    # per minute to the same member, and a daily quota by account size. This
    # only keeps the queue from stampeding; start conservative and raise it on
    # observed latency rather than guesswork.
    concurrency_limit -> { 10 }

    # WeCom gives no delivery guarantee, so a long retry tail buys nothing and
    # keeps re-sending a notification that is no longer timely.
    sidekiq_options retry: 3

    EXCERPT_LIMIT = 120
    # RFC 3676 signature delimiter, written by the notification text layout
    # ahead of its links and footer.
    SIGNATURE_MARKER = /^-- $/
    URL = %r{https?://\S+}
    REASSIGNMENT_ACTIONS = %w[reassigned_issue_email reassigned_merge_request_email].freeze

    sidekiq_retries_exhausted do |job, exception|
      Gitlab::AppLogger.error(
        message: 'Giving up on a WeCom notification',
        Labkit::Fields::CLASS_NAME => name,
        wecom_event: job['args']&.first,
        Labkit::Fields::ERROR_TYPE => exception.class.name
      )
    end

    def perform(event, serialized_args, serialized_kwargs)
      return unless ::Gitlab::Wecom::App.notifications_available?

      mailer = render(event, serialized_args, serialized_kwargs)
      return if mailer.nil?

      # The mailer decides who the notification is for, so the card follows the
      # email's own addressee rather than a second opinion formed here.
      address = mailer.message.to&.first
      return if address.blank?

      user = ::User.find_by_any_email(address)
      return unless ::JH::Users::WecomNotification.enabled_for?(user)

      wecom_user_id = ::JH::Users::WecomNotification.wecom_user_id_for(user)
      return if wecom_user_id.nil?

      deliver(wecom_user_id, mailer, event)
    end

    private

    # Rendering the notification a second time is the price of taking the card
    # from the email itself: the title and the link are then exactly what the
    # recipient's own email said, and no event needs code of its own here.
    #
    # A notification whose subject has since been deleted renders nothing. That
    # is not worth a retry, so it is logged and dropped.
    def render(event, serialized_args, serialized_kwargs)
      args = ::ActiveJob::Arguments.deserialize(serialized_args)
      kwargs = ::ActiveJob::Arguments.deserialize([serialized_kwargs]).first

      ::Notify.new.tap do |mailer|
        kwargs.blank? ? mailer.process(event, *args) : mailer.process(event, *args, **kwargs)
      end
    rescue StandardError => e
      Gitlab::AppLogger.info(
        build_structured_payload_labkit(
          message: 'Could not build a WeCom notification',
          wecom_event: event,
          Labkit::Fields::ERROR_TYPE => e.class.name
        )
      )
      nil
    end

    def deliver(wecom_user_id, mailer, event)
      result = ::Gitlab::Wecom::AppClient.new.send_card([wecom_user_id], card_for(mailer))

      return unless result.partial?

      # A member outside the app's visible range, or without a licence seat.
      # Retrying sends the same rejected recipient again.
      Gitlab::AppLogger.info(
        build_structured_payload_labkit(
          message: 'WeCom rejected a notification recipient',
          wecom_event: event
        )
      )
    rescue ::Gitlab::Wecom::AppClient::PermanentError => e
      Gitlab::AppLogger.error(
        build_structured_payload_labkit(
          message: 'WeCom refused a notification',
          wecom_event: event,
          Labkit::Fields::ERROR_MESSAGE => e.message
        )
      )
    end

    def card_for(mailer)
      message = mailer.message

      ::Gitlab::Wecom::NotificationCard.new(
        title: message.subject,
        # The layout renders this as "View it on GitLab" and every notification
        # sets it, so it is the one link available without knowing the event.
        # It has no reader; losing it costs the card its link, nothing more.
        url: mailer.instance_variable_get(:@target_url),
        project: message.header['X-GitLab-Project']&.value,
        reason: message.header['X-GitLab-NotificationReason']&.value,
        excerpt: excerpt_from(message, action: mailer.action_name)
      ).to_h
    end

    # The plain-text part of the notification, down to the signature marker the
    # layout writes before its links and footer. Taking it from the email keeps
    # the card's wording identical to the email's, for every event at once.
    #
    # A confidential discussion is quoted nowhere: the card leaves the instance
    # for a third party, so it travels as a title and a link only, and reading
    # it still goes through GitLab's own access checks.
    def excerpt_from(message, action:)
      return if ::Gitlab::Utils.to_boolean(message.header['X-GitLab-ConfidentialIssue']&.value)

      text = message.text_part&.decoded || message.body&.decoded
      body = text.to_s.split(SIGNATURE_MARKER).first.to_s

      # Omit the generic reassignment title because it obscures the localized assignee change.
      body = body.sub(/^Reassigned (?:Issue|merge request) \d+\r?\n/, '') if REASSIGNMENT_ACTIONS.include?(action)

      # Links are dropped: the card is already a link, and a URL would eat most
      # of the room the quote block has.
      body.gsub(URL, ' ').split("\n").map(&:strip).reject(&:empty?).join(' ').truncate(EXCERPT_LIMIT)
    end
  end
end
