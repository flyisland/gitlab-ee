# frozen_string_literal: true

module Mcp
  module Audit
    # Builds an `AuditEvents::AiAuditEvent` for an MCP session or tool call and
    # hands it to the existing AI audit pipeline, which applies the
    # `ai_audit_events_storage_enabled` gate, streams to external destinations
    # and writes `audit_json.log`.
    class CaptureEventService
      include ::Gitlab::Utils::StrongMemoize

      EVENT_NAMES = {
        session_started: 'ai_agent_session_started',
        session_ended: 'ai_agent_session_ended',
        tool_invoked: 'ai_tool_invoked',
        tool_failed: 'ai_tool_execution_failed'
      }.freeze

      # Distinguishes GitLab's own MCP server from the external servers a
      # namespace can register, so a reader can tell which one served the call.
      MCP_SERVER = 'core'
      TOOL_NAME_LIMIT = 255
      ERROR_MESSAGE_LIMIT = 255
      ARGUMENTS_BYTE_CAP = 10.kilobytes
      ARGUMENTS_OMITTED = { 'omitted' => 'arguments exceeded size limit' }.freeze

      def initialize(
        current_user:, session:, kind:, tool_name: nil, arguments: nil, error: nil,
        duration_s: nil)
        # Checked here rather than left to `EVENT_NAMES.fetch` in `execute`, so an
        # unmapped kind names itself at the boundary instead of surfacing as a
        # KeyError from inside the event build.
        raise ArgumentError, "unknown MCP audit kind: #{kind.inspect}" unless EVENT_NAMES.key?(kind)

        @current_user = current_user
        @session = session
        @kind = kind
        @tool_name = tool_name
        @arguments = arguments
        @error = error
        @duration_s = duration_s
      end

      def execute
        ::Ai::DuoWorkflows::ProcessAuditEventsWorker.perform_async([job_attributes])
      end

      private

      attr_reader :current_user, :session, :kind, :tool_name, :arguments, :error, :duration_s

      # `attributes` returns typecast values - `created_at` as a TimeWithZone,
      # `ip_address` as an IPAddr, and tool arguments as a
      # HashWithIndifferentAccess - all of which Sidekiq rejects as non-native
      # JSON. The worker rebuilds the record, so these forms typecast back.
      def job_attributes
        audit_event.attributes.tap do |attrs|
          attrs['created_at'] = attrs['created_at'].iso8601(6)
          attrs['ip_address'] = attrs['ip_address']&.to_s
          attrs['details'] = attrs['details'].as_json
        end
      end

      def audit_event
        ::AuditEvents::AiAuditEvent.new(
          cloud_event_id: SecureRandom.uuid,
          created_at: Time.current,
          author_id: current_user.id,
          ai_governance_session_id: session.id,
          **sharding_scope,
          event_name: EVENT_NAMES.fetch(kind),
          ip_address: ::Gitlab::ApplicationContext.current_context_attribute(:remote_ip),
          details: details
        )
      end

      # Exactly one of the two, per `check_547b01c40f`. Taken from the session so
      # `ai_audit_events_storage_enabled` is evaluated once per session and a
      # session cannot be half-stored. `project_id` wins because a project-scoped
      # session holds the project namespace, which that setting does not cascade
      # through.
      def sharding_scope
        { project_id: session.project_id, namespace_id: session.project_id ? nil : session.namespace_id }
      end

      def details
        {
          'mcp_server' => MCP_SERVER,
          'agent_initiated' => true,
          'agent_name' => session.agent_type,
          'oauth_application_id' => oauth_application_id,
          'oauth_application_name' => oauth_application_name,
          'tool_name' => tool_name&.to_s&.truncate(TOOL_NAME_LIMIT),
          'outcome' => outcome,
          'duration_s' => duration_s,
          'error_class' => error_class,
          'error_message' => error_message,
          'arguments' => capped_arguments
        }.compact
      end

      def oauth_application_id
        ::Current.token_info&.dig(:token_application_id)
      end
      strong_memoize_attr :oauth_application_id

      # The application name exactly as stored, including GitLab's
      # "[Unverified Dynamic Application]" prefix. `agent_name` holds the
      # normalised slug for analytics; this keeps the client's own unverified
      # claim in the record so the two can be compared.
      def oauth_application_name
        return unless oauth_application_id

        ::Authn::OauthApplication.find_by_id(oauth_application_id)&.name
      end
      strong_memoize_attr :oauth_application_name

      # CE wraps an `isError` response in a synthetic ToolResponseError before
      # the hook sees it, so a failure always arrives as an exception.
      def error_class
        return unless error

        error.class.name
      end

      def error_message
        return unless error

        error.message.truncate(ERROR_MESSAGE_LIMIT)
      end

      # Only tool events carry an outcome; a session event has none.
      def outcome
        case kind
        when :tool_invoked then 'pending'
        when :tool_failed then 'error'
        end
      end

      # `details` is an unbounded text column while the streamed payload is
      # encoded with a hard limit, so an unusually large argument set is replaced
      # rather than stored. The cap is measured on the JSON form and `details` is
      # serialised separately, so it bounds the order of magnitude, not the exact
      # stored bytes.
      def capped_arguments
        return if arguments.blank?

        ::Gitlab::Json.dump(arguments).bytesize > ARGUMENTS_BYTE_CAP ? ARGUMENTS_OMITTED : arguments
      # Tool arguments are caller-supplied bytes, so invalid UTF-8 reaches the
      # dump. EncodingError covers Encoding::UndefinedConversionError too.
      rescue ::JSON::GeneratorError, ::EncodingError
        ARGUMENTS_OMITTED
      end
    end
  end
end
