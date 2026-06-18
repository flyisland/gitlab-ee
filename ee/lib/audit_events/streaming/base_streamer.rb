# frozen_string_literal: true

module AuditEvents
  module Streaming
    class BaseStreamer
      include Gitlab::InternalEventsTracking

      INTERNAL_EVENTS = %w[delete_epic delete_issue delete_merge_request delete_work_item].freeze
      STREAMABLE_NOT_IMPLEMENTED_MESSAGE = 'Subclasses must implement the `streamable?` method'
      DESTINATIONS_NOT_IMPLEMENTED_MESSAGE = 'Subclasses must implement the `destinations` method'
      STREAMER_CATEGORY_NOT_FOUND_MESSAGE = 'Streamer class for category not found'

      # Errors originating from user-supplied configuration (invalid credentials,
      # malformed URLs, unreachable endpoints, non-actionable service responses,
      # bad payloads). These are not actionable by GitLab, so we log them
      # without paging Sentry. See commit fde68cd6bd7e.
      USER_CONFIG_ERRORS = [
        Aws::S3::Errors::ServiceError,
        URI::InvalidURIError,
        JSON::ParserError,
        OpenSSL::PKey::RSAError,
        Signet::AuthorizationError,
        *Gitlab::HTTP::HTTP_ERRORS
      ].freeze

      attr_reader :event_type, :audit_event

      STREAMER_DESTINATIONS = {
        'aws' => AuditEvents::Streaming::Destinations::AmazonS3StreamDestination,
        'gcp' => AuditEvents::Streaming::Destinations::GoogleCloudLoggingStreamDestination,
        'http' => AuditEvents::Streaming::Destinations::HttpStreamDestination
      }.freeze

      def initialize(event_type, audit_event)
        @event_type = event_type
        @audit_event = audit_event
      end

      def streamable?
        raise NotImplementedError, _(STREAMABLE_NOT_IMPLEMENTED_MESSAGE)
      end

      def execute
        return unless streamable?

        eligible_destinations = AuditEvents::Streaming::CircuitBreaker.reject_open(destinations.to_a)

        eligible_destinations.each do |destination|
          track_and_stream(destination) if destination.allowed_to_stream?(event_type, audit_event)
        end
      end

      private

      def destinations
        raise NotImplementedError, _(DESTINATIONS_NOT_IMPLEMENTED_MESSAGE)
      end

      def track_and_stream(destination)
        track_audit_event
        stream_to_destination(destination)

        log_streaming_success(destination)
        AuditEvents::Streaming::CircuitBreaker.record_success(destination)
      rescue StandardError => e
        context = {
          destination_id: destination.id,
          destination_name: destination.name,
          destination_category: destination.category
        }

        if log_only_error?(e, destination)
          Gitlab::ErrorTracking.log_exception(e, context)
          AuditEvents::Streaming::CircuitBreaker.record_failure(destination)
        else
          Gitlab::ErrorTracking.track_exception(e, context)
        end
      end

      def log_only_error?(error, destination)
        return true if USER_CONFIG_ERRORS.any? { |klass| error.is_a?(klass) }

        streamer_cls = STREAMER_DESTINATIONS[destination.category]
        return false unless streamer_cls

        streamer_cls.log_only_errors.any? { |klass| error.is_a?(klass) }
      end

      def stream_to_destination(destination)
        streamer_cls = STREAMER_DESTINATIONS[destination.category]

        raise ArgumentError, _(STREAMER_CATEGORY_NOT_FOUND_MESSAGE) unless streamer_cls

        streamer = streamer_cls.new(event_type, audit_event, destination)
        streamer.stream
      end

      def log_streaming_success(destination)
        Gitlab::AppLogger.info(
          message: 'Audit event streamed',
          destination_id: destination.id,
          destination_name: destination.name,
          destination_category: destination.category,
          event_type: event_type
        )
      end

      def track_audit_event
        return unless event_type.in?(INTERNAL_EVENTS)

        track_internal_event("trigger_audit_event", additional_properties: { label: event_type })
      end
    end
  end
end
