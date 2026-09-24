# frozen_string_literal: true

module Gitlab
  module Wecom
    # Stands in for Notify inside NotificationService so that every notification
    # the mailer sends also reaches WeCom.
    #
    # Sitting on the mailer rather than on individual events is the whole point:
    # there is no per-event WeCom code to keep in step with upstream, and what
    # reaches WeCom is by construction what reaches email. Adding a notification
    # upstream needs no work here.
    #
    # The delivery object is handed back untouched. Callers keep it, inspect it
    # and deliver it themselves, so wrapping it would put this class in the way
    # of code that has nothing to do with WeCom.
    #
    # Only mailer actions travel through method_missing, and each one is taken
    # to be a notification. NotificationService calls them by name, through
    # #send or through #public_send, and asks #respond_to? first; anything
    # Object already answers keeps its own meaning and enqueues nothing.
    class MailerFanout
      def initialize(mailer)
        @mailer = mailer
      end

      def respond_to_missing?(name, include_private = false)
        @mailer.respond_to?(name, include_private) || super
      end

      def method_missing(name, *args, **kwargs, &block)
        # The name comes from NotificationService's own call, never from a
        # request; forwarding it is what this class is for.
        delivery = @mailer.public_send(name, *args, **kwargs, &block) # rubocop:disable GitlabSecurity/PublicSend -- forwarding an in-process call

        enqueue(name, args, kwargs)

        delivery
      end

      private

      attr_reader :mailer

      # Arguments are serialized the way deliver_later serializes them, so
      # anything the mailer can be handed asynchronously survives the trip.
      def enqueue(event, args, kwargs)
        ::Wecom::SendNotificationWorker.perform_async(
          event.to_s,
          ::ActiveJob::Arguments.serialize(args),
          ::ActiveJob::Arguments.serialize([kwargs]).first
        )
      rescue StandardError => e
        # The email has already been built by the time we get here. A WeCom
        # problem must not cost it.
        ::Gitlab::ErrorTracking.track_exception(e, wecom_event: event.to_s)
      end
    end
  end
end
