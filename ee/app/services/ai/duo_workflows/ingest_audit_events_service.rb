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
        if @events.size > MAX_EVENTS_PER_REQUEST
          return ServiceResponse.error(
            message: "Batch size #{@events.size} exceeds maximum of #{MAX_EVENTS_PER_REQUEST}",
            reason: :bad_request
          )
        end

        audit_events = build_audit_events

        if audit_events.any?
          ::Ai::DuoWorkflows::ProcessAuditEventsWorker.perform_async(
            audit_events.map(&:attributes)
          )
        end

        payload = { status: 'accepted', count: audit_events.size }
        payload[:dropped_unknown_event_types] = unknown_event_names if unknown_event_names.any?

        ServiceResponse.success(payload: payload)
      end

      private

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
    end
  end
end
