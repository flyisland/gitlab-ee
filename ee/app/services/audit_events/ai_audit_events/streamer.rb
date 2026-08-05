# frozen_string_literal: true

module AuditEvents
  module AiAuditEvents
    class Streamer
      def self.stream(ai_audit_event)
        new(ai_audit_event).execute
      end

      def initialize(ai_audit_event)
        @ai_audit_event = ai_audit_event
      end

      def execute
        return if ::Gitlab::SilentMode.enabled?
        return unless instance_streaming_enabled?

        ::AuditEvents::AiAuditEventStreamingWorker.perform_async(@ai_audit_event.streaming_json)
      end

      private

      def instance_streaming_enabled?
        !!::Gitlab::CurrentSettings.ai_audit_events_streaming_enabled
      end
    end
  end
end
