# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class IngestAuditEventsService
      MAX_EVENTS_PER_REQUEST = 500

      def initialize(workflow:, events:, current_user:)
        @workflow = workflow
        @events = Array(events)
        @current_user = current_user
      end

      def execute
        return ServiceResponse.success(payload: { status: 'accepted', count: 0 }) unless feature_flag_enabled?

        if @events.size > MAX_EVENTS_PER_REQUEST
          return ServiceResponse.error(
            message: "Batch size #{@events.size} exceeds maximum of #{MAX_EVENTS_PER_REQUEST}",
            reason: :bad_request
          )
        end

        audit_events = build_audit_events
        store_audit_events(audit_events)
        stream_audit_events(audit_events)
        log_audit_events(audit_events)

        payload = { status: 'accepted', count: audit_events.size }
        payload[:dropped_unknown_event_types] = unknown_event_names if unknown_event_names.any?

        ServiceResponse.success(payload: payload)
      end

      private

      def feature_flag_enabled?
        ::Feature.enabled?(:duo_workflow_audit_events, root_namespace)
      end

      def root_namespace
        (@workflow.project || @workflow.namespace)&.root_ancestor
      end

      def unknown_event_names
        @unknown_event_names ||= begin
          payload_event_names = @events.filter_map { |event| event[:type].presence }.uniq
          (payload_event_names - ::AuditEvents::AiAuditEvent::ALLOWED_EVENT_NAMES).sort
        end
      end

      def build_audit_events
        @events.filter_map do |event|
          next if reject_event?(event)
          next unless ::AuditEvents::AiAuditEvent::ALLOWED_EVENT_NAMES.include?(event[:type])

          ::AuditEvents::AiAuditEvent.new(
            cloud_event_id: event[:id],
            event_name: event[:type],
            created_at: event[:time],
            author_id: @current_user.id,
            project_id: @workflow.project_id,
            namespace_id: @workflow.namespace_id,
            ip_address: event.dig(:data, :ip_address),
            workflow_id: @workflow.id,
            details: event[:data] || {}
          )
        end
      end

      def reject_event?(event)
        return true if event[:id].blank?
        return true if event[:type].blank?
        return true if event[:time].blank?

        false
      end

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
