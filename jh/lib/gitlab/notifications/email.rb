# frozen_string_literal: true

module Gitlab
  module Notifications
    class Email
      include ::Gitlab::Loggable

      EXCERPT_LIMIT = 120
      SIGNATURE_MARKER = /^-- $/
      URL = %r{https?://\S+}
      REASSIGNMENT_ACTIONS = %w[reassigned_issue_email reassigned_merge_request_email].freeze

      attr_reader :mailer

      def self.render(event, serialized_args, serialized_kwargs)
        return unless ::Notify.action_methods.include?(event)

        args = ::ActiveJob::Arguments.deserialize(serialized_args)
        kwargs = ::ActiveJob::Arguments.deserialize([serialized_kwargs]).first
        mailer = ::Notify.new
        kwargs.blank? ? mailer.process(event, *args) : mailer.process(event, *args, **kwargs)
        new(mailer)
      rescue StandardError => e
        ::Gitlab::AppLogger.info(
          message: 'Could not build a notification card',
          Labkit::Fields::CLASS_NAME => name,
          Labkit::Fields::ERROR_TYPE => e.class.name
        )
        nil
      end

      def initialize(mailer)
        @mailer = mailer
      end

      def recipient
        address = mailer.message.to&.first
        ::User.find_by_any_email(address) if address.present?
      end

      def attributes
        message = mailer.message
        confidential = confidential?(message)
        {
          title: message.subject,
          url: mailer.instance_variable_get(:@target_url),
          project: confidential ? nil : message.header['X-GitLab-Project']&.value,
          reason: confidential ? nil : message.header['X-GitLab-NotificationReason']&.value,
          excerpt: confidential ? nil : excerpt_from(message, action: mailer.action_name)
        }
      end

      private

      def confidential?(message)
        return true if ::Gitlab::Utils.to_boolean(message.header['X-GitLab-ConfidentialIssue']&.value)

        note = mailer.instance_variable_get(:@note)
        return true if note && (note.internal? || note.confidential?(include_noteable: true))

        %i[@issue @epic].any? { |name| mailer.instance_variable_get(name)&.confidential? }
      end

      def excerpt_from(message, action:)
        text = message.text_part&.decoded || message.body&.decoded
        body = text.to_s.split(SIGNATURE_MARKER).first.to_s

        body = body.sub(/^Reassigned (?:Issue|merge request) \d+\r?\n/, '') if REASSIGNMENT_ACTIONS.include?(action)

        body.gsub(URL, ' ').split("\n").map(&:strip).reject(&:empty?).join(' ').truncate(EXCERPT_LIMIT)
      end
    end
  end
end
