# frozen_string_literal: true

module Gitlab
  module Notifications
    class MailerFanout
      def self.available?
        Channels.available?
      end

      def initialize(mailer)
        @mailer = mailer
      end

      def respond_to_missing?(name, include_private = false)
        @mailer.respond_to?(name, include_private) || super
      end

      def method_missing(name, *args, **kwargs, &block)
        delivery = @mailer.public_send(name, *args, **kwargs, &block) # rubocop:disable GitlabSecurity/PublicSend -- forwarding an in-process mailer call
        enqueue(name, args, kwargs)
        delivery
      end

      private

      def enqueue(event, args, kwargs)
        ::Notifications::FanoutWorker.perform_async(
          event.to_s, ::ActiveJob::Arguments.serialize(args),
          ::ActiveJob::Arguments.serialize([kwargs]).first, SecureRandom.uuid
        )
      rescue StandardError => e
        ::Gitlab::AppLogger.error(
          message: 'Could not queue notification cards',
          Labkit::Fields::CLASS_NAME => self.class.name,
          Labkit::Fields::ERROR_TYPE => e.class.name
        )
      end
    end
  end
end
