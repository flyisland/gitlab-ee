# frozen_string_literal: true

module EE
  module Gitlab
    module Audit
      module Auditor
        extend ::Gitlab::Utils::Override

        override :multiple_audit
        def multiple_audit
          ::Gitlab::Audit::EventQueue.begin!

          return_value = yield

          ::Gitlab::Audit::EventQueue.current
            .map { |audit| audit.is_a?(AuditEvent) ? audit : build_event(audit) }
            .then { |events| record(events) }

          return_value
        ensure
          ::Gitlab::Audit::EventQueue.end!
        end

        override :send_to_stream
        def send_to_stream(events)
          events.each do |event|
            event_name = name
            event.run_after_commit_or_now do
              event.stream_to_external_destinations(use_json: true, event_name: event_name)
            end
          end
        end

        override :audit_enabled?
        def audit_enabled?
          return true if super
          return true if ::License.feature_available?(:admin_audit_log)
          return true if ::License.feature_available?(:extended_audit_events)

          scope.respond_to?(:licensed_feature_available?) && scope.licensed_feature_available?(:audit_events)
        end

        override :log_events_and_stream
        def log_events_and_stream(events)
          log_authentication_event
          saved_events = log_to_database(events)

          # When legacy writes are skipped (saved_events is nil), pass original events to log_to_new_tables.
          # The new tables will generate their own IDs using the shared sequence.
          events_for_new_tables = saved_events.presence || events
          new_audit_events = log_to_new_tables(events_for_new_tables, name)

          events_to_stream = new_audit_events.presence || saved_events.presence || events
          log_to_file_and_stream(events_to_stream)
        end
      end
    end
  end
end
