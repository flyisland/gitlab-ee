# frozen_string_literal: true

module AuditEvents
  class AiAuditEventStreamingWorker
    include ApplicationWorker

    # AI audit events contain a `cloud_event_id` UUID; ingesting systems should
    # deduplicate based on that to make this job safely retryable.
    idempotent!
    worker_has_external_dependencies!
    data_consistency :sticky
    feature_category :audit_events
    sidekiq_options retry: 3

    def perform(audit_event_json)
      return if ::Gitlab::SilentMode.enabled?

      ai_audit_event = build_audit_event(audit_event_json)
      return if ai_audit_event.nil?

      ::AuditEvents::ExternalDestinationStreamer
        .new(ai_audit_event.event_name, ai_audit_event)
        .stream_to_destinations
    end

    private

    def build_audit_event(audit_event_json)
      payload = ::Gitlab::Json.safe_parse(audit_event_json).with_indifferent_access

      attrs = payload.slice(*::AuditEvents::AiAuditEvent::STREAMABLE_ATTRIBUTES)
      ai_audit_event = ::AuditEvents::AiAuditEvent.new(attrs)
      ai_audit_event.root_group_entity_id = payload[:root_group_entity_id]
      ai_audit_event
    rescue JSON::ParserError => e
      ::Gitlab::ErrorTracking.track_exception(e)
      nil
    end
  end
end
