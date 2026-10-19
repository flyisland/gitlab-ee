# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    class QueryRunner
      Response = Data.define(:status, :content_type, :body) do
        def self.json(body, status: 200)
          new(status: status, content_type: JSON_TYPE, body: "#{body}\n")
        end

        def self.text(body, status: 200)
          new(status: status, content_type: TEXT_TYPE, body: body)
        end
      end

      class RestRenderer
        def ok(body, type:)
          type == :json ? Response.json(body) : Response.text(body)
        end

        def query_error(code, message, reason)
          payload = { code: code, message: message }
          payload[:reason] = reason if reason.present?
          Response.json(::Gitlab::Json.generate(payload), status: ERROR_HTTP_STATUS.fetch(code, 400))
        end

        def failure(_message, status)
          Response.text("#{Rack::Utils::HTTP_STATUS_CODES[status]}\n", status: status)
        end
      end

      McpRenderer = Struct.new(:id) do
        def self.tool_result(text, is_error:)
          { content: [{ type: 'text', text: text }], isError: is_error }
        end

        def ok(body, **)
          envelope(body, is_error: false)
        end

        def query_error(_code, message, _reason)
          envelope(message, is_error: true)
        end

        def failure(message, _status)
          envelope(message, is_error: true)
        end

        private

        def envelope(text, is_error:)
          result = self.class.tool_result(text, is_error:)
          Response.json(::Gitlab::Json.generate(jsonrpc: '2.0', result: result, id: id))
        end
      end

      class StreamFailure < StandardError
        attr_reader :http_status

        def initialize(message, http_status)
          super(message)
          @http_status = http_status
        end
      end

      RetryableError = Class.new(StandardError)
      ClientClosed = Class.new(StandardError)

      METHOD = '/orbit.v1.OrbitService/ExecuteQuery'
      MAX_STREAM_MESSAGES = 10
      MAX_TIMEOUT_SECONDS = 120
      RACK_TIMEOUT_MARGIN_SECONDS = 2
      MAX_ATTEMPTS = 2
      REDACTION_SOURCE = 'orbit_rails'
      JSON_TYPE = 'application/json'
      TEXT_TYPE = 'text/plain; charset=utf-8'
      CLIENT_CLOSED_STATUS = 499
      TIMEOUT_MESSAGE = 'orbit query: query did not finish in time, narrow the query and try again'
      STREAM_ERROR_MESSAGE = 'orbit query: stream error'
      CODE_QUOTA_EXHAUSTED = 'quota_exhausted'
      REASON_CREDITS_EXHAUSTED = 'GITLAB_CREDITS_EXHAUSTED'
      ERROR_HTTP_STATUS = {
        'compile_error' => 400,
        'validation_error' => 400,
        'execution_error' => 502,
        'internal_error' => 502,
        'timeout' => 504,
        CODE_QUOTA_EXHAUSTED => 402
      }.freeze
      PROTO_FORMATS = { 'llm' => :RESPONSE_FORMAT_LLM, 'gql' => :RESPONSE_FORMAT_GQL }.freeze
      OPS = ::GRPC::Core::CallOps
      CODES = ::GRPC::Core::StatusCodes

      def self.enabled_for?(user)
        Feature.enabled?(:orbit_query_in_rails, user)
      end

      def initialize(params, user:, env: {})
        @params = params
        @user = user
        @env = env
        @renderer = params['McpId'].nil? ? RestRenderer.new : McpRenderer.new(params['McpId'])
        @format = params['Format'].to_s
      end

      def execute
        start = ::Gitlab::Metrics::System.monotonic_time
        raise StreamFailure.new(TIMEOUT_MESSAGE, 504) if timeout_seconds <= 0

        release_request_resources!
        response = run_with_retry
        observe_grpc(start, @failed ? 'error' : 'ok')
        response
      rescue ClientClosed
        observe_grpc(start, 'cancelled')
        Response.text('', status: CLIENT_CLOSED_STATUS)
      rescue StreamFailure => e
        observe_grpc(start, 'error')
        fail_query(e.message, e.http_status)
      rescue StandardError => e
        ::Gitlab::ErrorTracking.track_exception(e, user_id: user.id)
        observe_grpc(start, 'error')
        fail_query('orbit query: internal error', 502)
      end

      private

      attr_reader :params, :user, :env, :renderer, :format

      def run_with_retry
        attempt = 0
        begin
          attempt += 1
          run_stream
        rescue RetryableError
          retry if attempt < MAX_ATTEMPTS && !deadline_passed?

          raise StreamFailure.new(STREAM_ERROR_MESSAGE, 502)
        end
      end

      def run_stream
        call = GrpcClient.channel(params.dig('GkgServer', 'address'))
          .create_call(nil, ::GRPC::Core::PropagateMasks::DEFAULTS, METHOD, nil, deadline)
        received = false
        watch = DisconnectWatcher.watch(env['puma.socket'], call)

        begin
          call.run_batch(OPS::SEND_INITIAL_METADATA => metadata, OPS::SEND_MESSAGE => initial_message.to_proto)
        rescue ::GRPC::Core::CallError
          return stream_ended(call, watch, received)
        end

        MAX_STREAM_MESSAGES.times do
          batch = call.run_batch(received ? recv_ops : recv_ops.merge(OPS::RECV_INITIAL_METADATA => nil))
          return stream_ended(call, watch, received) if batch.message.nil?

          received = true
          response = dispatch(call, watch, ::Orbit::V1::ExecuteQueryMessage.decode(batch.message))
          return response if response
        end

        raise StreamFailure.new("orbit query: exceeded #{MAX_STREAM_MESSAGES} stream messages without result", 502)
      rescue ::GRPC::Core::CallError => e
        call_failed(watch, e)
      ensure
        call&.cancel
        call&.close
        DisconnectWatcher.unwatch(watch)
      end

      def dispatch(call, watch, msg)
        case msg.content
        when :redaction
          raise ClientClosed if watch&.cancelled

          reply = redaction_reply(msg.redaction.required)
          call.run_batch(OPS::SEND_MESSAGE => reply.to_proto) if reply
          nil
        when :result
          finish(call)
          result_response(msg.result)
        when :error
          finish(call)
          query_error(msg.error.code, msg.error.message)
        end
      end

      def call_failed(watch, error)
        raise ClientClosed if watch&.cancelled

        metrics.increment_grpc_error('execute_query', 'call_error')
        raise StreamFailure.new(TIMEOUT_MESSAGE, 504) if deadline_passed?

        log_error('call_error', error.message)
        raise StreamFailure.new(STREAM_ERROR_MESSAGE, 502)
      end

      def recv_ops
        { OPS::RECV_MESSAGE => nil }
      end

      def finish(call)
        call.run_batch(OPS::SEND_CLOSE_FROM_CLIENT => nil, OPS::RECV_STATUS_ON_CLIENT => nil)
      rescue ::GRPC::Core::CallError
        nil
      end

      def stream_ended(call, watch, received)
        status = call.run_batch(OPS::RECV_STATUS_ON_CLIENT => nil).status
        raise ClientClosed if watch&.cancelled

        metrics.increment_grpc_error('execute_query', status.code.to_s)

        if status.code == CODES::RESOURCE_EXHAUSTED && deny_reason(status) == REASON_CREDITS_EXHAUSTED
          return query_error(CODE_QUOTA_EXHAUSTED, status.details, REASON_CREDITS_EXHAUSTED)
        end

        raise StreamFailure.new(TIMEOUT_MESSAGE, 504) if status.code == CODES::DEADLINE_EXCEEDED || deadline_passed?
        raise RetryableError if status.code == CODES::UNAVAILABLE && !received
        raise StreamFailure.new('orbit query: stream ended without result', 502) if status.code == CODES::OK

        error = GrpcClient::ConnectionError.new(
          'execute_query failed', grpc_code: status.code, grpc_details: status.details
        )
        return query_error('invalid_request', status.details) if error.client_error? && status.details.present?

        log_error('stream_status', "#{status.code}: #{status.details}")
        raise StreamFailure.new(STREAM_ERROR_MESSAGE, 502)
      end

      def deny_reason(status)
        rpc_status = ::GRPC::BadStatus.new_status_exception(status.code, status.details, status.metadata).to_rpc_status
        return unless rpc_status

        require 'google/rpc/error_details_pb'
        rpc_status.details.each do |any|
          info = any.unpack(::Google::Rpc::ErrorInfo)
          return info.reason if info
        end
        nil
      end

      def redaction_reply(required)
        return unless required

        results = redact(required.resources)
        ::Orbit::V1::ExecuteQueryMessage.new(
          redaction: ::Orbit::V1::RedactionExchange.new(
            response: ::Orbit::V1::RedactionResponse.new(
              result_id: required.result_id,
              authorizations: results.map do |type, id_map|
                ::Orbit::V1::ResourceAuthorization.new(resource_type: type, authorized: id_map)
              end
            )
          )
        )
      end

      def redact(resources)
        resources_by_type = {}
        resources.each do |r|
          r.abilities.each do |ability|
            if resources_by_type.key?(r.resource_type)
              raise StreamFailure.new("orbit query: duplicate resource_type '#{r.resource_type}'", 502)
            end

            resources_by_type[r.resource_type] = { 'ids' => r.resource_ids.to_a, 'ability' => ability }
          end
        end

        ::Authz::RedactionService.new(
          user: user, resources_by_type: resources_by_type, source: REDACTION_SOURCE,
          metrics_observer: method(:observe_redaction)
        ).execute
      ensure
        release_request_resources!
      end

      def result_response(result)
        return renderer.ok(result.formatted_text, type: :text) if PROTO_FORMATS.key?(format)

        renderer.ok(raw_body(result), type: :json)
      end

      def raw_body(result)
        md = result.metadata || ::Orbit::V1::QueryMetadata.new
        raw = result.result_json
        strings = md.raw_query_strings.to_a

        payload = { result: raw.empty? ? '' : ::JSON::Fragment.new(raw), query_type: md.query_type }
        payload[:raw_query_strings] = strings if strings.any?
        payload[:row_count] = md.row_count
        ::Gitlab::Json.generate(payload)
      end

      def query_error(code, message, reason = nil)
        @failed = true
        renderer.query_error(code, message, reason)
      end

      def fail_query(message, http_status)
        log_error('fail_query', message)
        renderer.failure(message, http_status)
      end

      def initial_message
        ::Orbit::V1::ExecuteQueryMessage.new(
          request: ::Orbit::V1::ExecuteQueryRequest.new(
            query: params['Query'],
            format: PROTO_FORMATS.fetch(format, :RESPONSE_FORMAT_RAW),
            query_type: params['QueryType'] == 'named' ? :QUERY_TYPE_NAMED : :QUERY_TYPE_JSON,
            language: params['Language'] == 'gql' ? :QUERY_LANGUAGE_GQL : :QUERY_LANGUAGE_JSON
          )
        )
      end

      def metadata
        GrpcClient.base_metadata.merge!(params.dig('GkgServer', 'headers').to_h)
      end

      def deadline
        @deadline ||= ::GRPC::Core::TimeConsts.from_relative_time(timeout_seconds)
      end

      def deadline_passed?
        Time.current >= deadline
      end

      def timeout_seconds
        @timeout_seconds ||= begin
          seconds = params['TimeoutSeconds'].to_i
          seconds = ::EE::Gitlab::Workhorse::ORBIT_DEFAULT_TIMEOUT_SECONDS if seconds <= 0
          [seconds, MAX_TIMEOUT_SECONDS, rack_timeout_remaining].compact.min
        end
      end

      def rack_timeout_remaining
        info = env[::Rack::Timeout::ENV_INFO_KEY]
        return unless info&.timeout

        info.timeout - info.service.to_f - RACK_TIMEOUT_MARGIN_SECONDS
      end

      def release_request_resources!
        ::ActiveRecord::Base.connection_handler.connection_pool_list(:all).each do |pool|
          pool.release_connection unless pool.active_connection&.transaction_open?
        end
        env['puma.mark_as_io_bound']&.call
      end

      def observe_redaction(total:, filtered:, duration:)
        metrics.observe_redaction_duration(duration)
        metrics.observe_redaction_batch_size(total)
        metrics.observe_redaction_filtered(filtered)
      end

      def observe_grpc(start, status)
        metrics.observe_grpc_duration('execute_query', status, ::Gitlab::Metrics::System.monotonic_time - start)
      end

      def metrics
        ::Gitlab::Metrics::KnowledgeGraph::Request
      end

      def log_error(event, message)
        ::Gitlab::KnowledgeGraph::Logger.build.error(
          message: "orbit query #{event}",
          ::Labkit::Fields::CLASS_NAME => self.class.name,
          ::Labkit::Fields::ERROR_MESSAGE => message,
          ::Labkit::Fields::GL_USER_ID => user.id
        )
      end
    end
  end
end
