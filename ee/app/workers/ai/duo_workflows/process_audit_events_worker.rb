# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class ProcessAuditEventsWorker
      include ApplicationWorker

      # Each event carries a `cloud_event_id` UUID; storage uses `skip_duplicates: true`
      # and the ClickHouse write buffer is idempotent on that key, so retries are safe.
      idempotent!
      data_consistency :sticky
      feature_category :audit_events
      urgency :low
      defer_on_database_health_signal :gitlab_main, [:ai_audit_events]

      # @param serialized_events [Array<Hash>] Array of AR attribute hashes for unsaved
      #   AuditEvents::AiAuditEvent objects, produced by the service before enqueuing.
      def perform(serialized_events)
        return if serialized_events.blank?

        audit_events = serialized_events.map { |attrs| ::AuditEvents::AiAuditEvent.new(attrs) }

        store_audit_events(audit_events)
        stream_audit_events(audit_events)
        log_audit_events(audit_events)
      end

      private

      def store_audit_events(audit_events)
        return if audit_events.empty?

        if ::Gitlab::ClickHouse.globally_enabled_for_analytics?
          audit_events.each(&:store_to_clickhouse)
        else
          ::AuditEvents::AiAuditEvent.bulk_insert!(
            audit_events,
            skip_duplicates: true,
            unique_by: %i[cloud_event_id created_at]
          )
        end
      end

      def stream_audit_events(audit_events)
        audit_events.each do |audit_event|
          ::AuditEvents::AiAuditEvents::Streamer.stream(audit_event)
        end
      end

      def log_audit_events(audit_events)
        logger = ::Gitlab::AuditJsonLogger.build

        audit_events.each do |audit_event|
          logger.info(
            event_name: audit_event.event_name,
            cloud_event_id: audit_event.cloud_event_id,
            author_id: audit_event.author_id,
            Labkit::Fields::REMOTE_IP => audit_event.ip_address.to_s,
            workflow_id: audit_event.workflow_id,
            project_id: audit_event.project_id,
            namespace_id: audit_event.namespace_id,
            details: audit_event.details,
            created_at: audit_event.created_at&.iso8601
          )
        end
      end
    end
  end
end
