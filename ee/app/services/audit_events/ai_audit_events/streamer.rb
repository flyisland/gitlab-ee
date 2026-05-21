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
        # TODO: replace with `Gitlab::CurrentSettings.ai_audit_events_streaming_enabled?`
        # once the instance-level setting lands. The setting will be off on GitLab.com.
        # Tracking issue: https://gitlab.com/gitlab-org/gitlab/-/work_items/596268
        false
      end
    end
  end
end
