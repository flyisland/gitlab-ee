# frozen_string_literal: true

require 'gkg'
require 'resolv'

module Analytics
  module KnowledgeGraph
    class GrpcClient
      include ::Gitlab::Loggable

      MUTEX = Mutex.new
      DEFAULT_TIMEOUT = 10
      STREAMING_TIMEOUT = 30
      DNS_RESOLUTION_TIMEOUT = 2
      DEFAULT_GRPC_ENDPOINT = 'localhost:50054'
      CHANNEL_ARGS = {
        'grpc.keepalive_time_ms' => 60_000,
        'grpc.keepalive_timeout_ms' => 20_000,
        'grpc.keepalive_permit_without_calls' => 1,
        'grpc.max_receive_message_length' => 8 * 1024 * 1024,
        'grpc.max_send_message_length' => 8 * 1024 * 1024
      }.freeze

      ExecutionError = Class.new(StandardError)
      StreamError = Class.new(StandardError)
      ConnectionError = Class.new(StandardError)
      AuthorizationError = Class.new(StandardError)

      class << self
        def stub(endpoint = nil)
          target = endpoint || configured_endpoint

          MUTEX.synchronize do
            @stubs ||= {}
            @stubs[target] ||= begin
              channel = create_channel(target)
              Gkg::V1::KnowledgeGraphService::Stub.new(
                channel.target,
                nil,
                interceptors: client_interceptors,
                channel_override: channel
              )
            end
          end
        end

        def clear_stubs!
          MUTEX.synchronize do
            @channels&.each_value(&:close)
            @channels = nil
            @stubs = nil
          end
        end

        def configured_endpoint
          Gitlab.config.knowledge_graph.grpc_endpoint
        rescue GitlabSettings::MissingSetting
          fallback = ENV.fetch('KNOWLEDGE_GRAPH_GRPC_ENDPOINT', DEFAULT_GRPC_ENDPOINT)
          ::Gitlab::KnowledgeGraph::Logger.build.warn(
            message: 'Knowledge Graph gRPC endpoint not configured, using fallback',
            fallback_endpoint: fallback
          )
          fallback
        end

        def secure_channel?(target)
          uri = URI(target)
          uri.scheme == 'tls' || uri.scheme == 'dns+tls'
        rescue URI::InvalidURIError
          false
        end

        def private_address?(target)
          host = extract_host(target)
          return true if host == 'localhost'

          ips = resolve_ips(host)
          ips.any? && ips.all? { |ip| private_ip?(ip) }
        end

        private

        def private_ip?(ip)
          addr = IPAddr.new(ip)
          addr.loopback? || addr.private?
        rescue IPAddr::InvalidAddressError
          false
        end

        def resolve_ips(host)
          IPAddr.new(host)
          [host]
        rescue IPAddr::InvalidAddressError
          resolver = Resolv::DNS.new
          resolver.timeouts = DNS_RESOLUTION_TIMEOUT
          begin
            resolver.getaddresses(host).map(&:to_s)
          rescue Resolv::ResolvError, Resolv::ResolvTimeout
            []
          ensure
            resolver.close
          end
        end

        # Not thread-safe on its own. Called from within `stub` which holds MUTEX.
        def create_channel(target)
          @channels ||= {}
          @channels[target] ||= GRPC::ClientStub.setup_channel(
            nil, strip_scheme(target), channel_credentials(target), CHANNEL_ARGS.dup
          )
        end

        def channel_credentials(target)
          uri = URI(target)

          if uri.scheme == 'tls' || uri.scheme == 'dns+tls'
            GRPC::Core::ChannelCredentials.new(::Gitlab::X509::Certificate.ca_certs_bundle)
          else
            :this_channel_is_insecure
          end
        rescue URI::InvalidURIError
          :this_channel_is_insecure
        end

        def strip_scheme(target)
          target.sub(%r{^tcp://|^tls://}, '').sub(%r{^dns\+tls:}, 'dns:')
        end

        def extract_host(target)
          uri = URI(target)
          uri.host || target.split(':').first
        rescue URI::InvalidURIError
          target.split(':').first
        end

        def client_interceptors
          interceptors = []
          interceptors << Labkit::Tracing::GRPC::ClientInterceptor.instance if Labkit::Tracing.enabled?
          interceptors
        end
      end

      def initialize(endpoint: nil)
        @endpoint = endpoint
      end

      def list_tools(user:, source_type:, timeout: DEFAULT_TIMEOUT)
        raise ArgumentError, 'user is required' unless user

        request = Gkg::V1::ListToolsRequest.new
        kwargs = request_kwargs(user: user, source_type: source_type, timeout: timeout)

        measure_grpc('list_tools') do
          response = stub.list_tools(request, **kwargs)

          response.tools.map do |tool|
            {
              name: tool.name,
              description: tool.description,
              parameters: safe_json_parse(tool.parameters_json_schema)
            }
          end
        end
      rescue GRPC::BadStatus => e
        handle_grpc_error('list_tools', e)
      end

      def execute_query(
        query:, user:, source_type:,
        format: :raw, query_type: :json, timeout: STREAMING_TIMEOUT # rubocop:disable Lint/UnusedMethodArgument -- query_type reserved for future query languages
      )
        raise ArgumentError, 'user is required' unless user

        metadata = auth_metadata(user: user, source_type: source_type)
        request_queue = Queue.new

        proto_format = format == :llm ? :RESPONSE_FORMAT_LLM : :RESPONSE_FORMAT_RAW

        initial_request = Gkg::V1::ExecuteQueryMessage.new(
          request: Gkg::V1::ExecuteQueryRequest.new(
            query: query.is_a?(String) ? query : query.to_json,
            format: proto_format,
            query_type: :QUERY_TYPE_JSON
          )
        )
        request_queue.push(initial_request)

        requests = build_request_enumerator(request_queue)
        responses = stub.execute_query(requests, metadata: metadata, deadline: build_deadline(timeout))

        measure_grpc('execute_query') do
          handle_query_stream(responses, request_queue, user: user)
        end
      rescue GRPC::BadStatus => e
        handle_grpc_error('execute_query', e)
      end

      def get_graph_schema(user:, source_type:, expand_nodes: [], format: :raw, timeout: DEFAULT_TIMEOUT)
        raise ArgumentError, 'user is required' unless user

        proto_format = format == :llm ? :RESPONSE_FORMAT_LLM : :RESPONSE_FORMAT_RAW

        request = Gkg::V1::GetGraphSchemaRequest.new(
          expand_nodes: expand_nodes,
          format: proto_format
        )
        kwargs = request_kwargs(user: user, source_type: source_type, timeout: timeout)

        measure_grpc('get_graph_schema') do
          response = stub.get_graph_schema(request, **kwargs)

          case response.content
          when :structured
            map_structured_schema(response.structured)
          when :formatted_text
            { formatted_text: response.formatted_text }
          else
            {}
          end
        end
      rescue GRPC::BadStatus => e
        handle_grpc_error('get_graph_schema', e)
      end

      def get_cluster_health(user:, source_type:, format: :raw, timeout: DEFAULT_TIMEOUT)
        raise ArgumentError, 'user is required' unless user

        proto_format = format == :llm ? :RESPONSE_FORMAT_LLM : :RESPONSE_FORMAT_RAW

        request = Gkg::V1::GetClusterHealthRequest.new(format: proto_format)
        kwargs = request_kwargs(user: user, source_type: source_type, timeout: timeout)

        response = measure_grpc('get_cluster_health') { stub.get_cluster_health(request, **kwargs) }

        case response.content
        when :structured
          structured = response.structured
          {
            status: cluster_status_to_string(structured.status),
            timestamp: structured.timestamp,
            version: structured.version,
            components: structured.components.map { |c| component_to_hash(c) }
          }
        when :formatted_text
          { formatted_text: response.formatted_text }
        else
          { status: 'unknown' }
        end
      rescue GRPC::BadStatus => e
        log_error('get_cluster_health', error: e.message, grpc_code: e.code)
        { status: 'unknown', error: 'Service unreachable' }
      end

      private

      def stub
        self.class.stub(@endpoint)
      end

      def request_kwargs(user:, source_type:, timeout: DEFAULT_TIMEOUT)
        {
          metadata: auth_metadata(user: user, source_type: source_type),
          deadline: build_deadline(timeout)
        }
      end

      def auth_metadata(user:, source_type:)
        target = @endpoint || self.class.configured_endpoint
        metadata = { 'client_name' => client_name }

        auth_header = JwtAuth.authorization_header(user: user, source_type: source_type)
        raise AuthorizationError, 'Failed to generate authorization header' unless auth_header

        if self.class.secure_channel?(target) || self.class.private_address?(target)
          metadata['authorization'] = auth_header
        else
          log_error('auth_metadata', message: 'Skipping authorization header on insecure non-private channel',
            target: target)
        end

        correlation_id = Labkit::Correlation::CorrelationId.current_id
        metadata['x-gitlab-correlation-id'] = correlation_id if correlation_id.present?
        metadata
      end

      def client_name
        Gitlab::Runtime.sidekiq? ? 'gitlab-sidekiq' : 'gitlab-web'
      end

      def build_deadline(timeout)
        GRPC::Core::TimeConsts.from_relative_time(timeout)
      end

      def build_request_enumerator(queue)
        Enumerator.new do |yielder|
          loop do
            msg = queue.pop
            break if msg == :done

            yielder << msg
          end
        end
      end

      def handle_query_stream(responses, request_queue, user:)
        responses.each do |msg|
          case msg.content
          when :redaction
            handle_redaction(msg.redaction, request_queue, user: user)
          when :result
            content = case msg.result.content
                      when :result_json
                        msg.result.result_json
                      when :formatted_text
                        msg.result.formatted_text
                      end
            metadata = msg.result.metadata
            return {
              result: content,
              query_type: metadata&.query_type,
              raw_query_strings: metadata&.raw_query_strings&.to_a,
              row_count: metadata&.row_count || 0
            }
          when :error
            raise ExecutionError, "#{msg.error.code}: #{msg.error.message}"
          end
        end

        raise StreamError, "Stream ended without result"
      ensure
        request_queue.push(:done)
      end

      def handle_redaction(redaction_exchange, request_queue, user:)
        redaction_req = redaction_exchange.required

        auth_results = authorize_resources(user, redaction_req.resources)

        response_exchange = Gkg::V1::RedactionExchange.new(
          response: Gkg::V1::RedactionResponse.new(
            result_id: redaction_req.result_id,
            authorizations: build_authorizations(auth_results)
          )
        )

        request_queue.push(Gkg::V1::ExecuteQueryMessage.new(redaction: response_exchange))
      end

      def authorize_resources(user, resources)
        resources_by_type = build_resources_by_type(resources)
        return {} if resources_by_type.empty?

        ::Authz::RedactionService.new(
          user: user,
          resources_by_type: resources_by_type,
          source: 'knowledge_graph',
          metrics_observer: redaction_metrics_observer
        ).execute
      rescue StandardError => e
        log_error('authorize_resources', error: e.message)
        {}
      end

      def build_resources_by_type(resources)
        resources.each_with_object({}) do |resource, hash|
          ids = resource.resource_ids.to_a
          abilities = resource.abilities.to_a

          next unless abilities.present? && ids.present?

          ability = abilities.first

          if hash.key?(resource.resource_type)
            hash[resource.resource_type]['ids'] |= ids
          else
            hash[resource.resource_type] = { 'ids' => ids, 'ability' => ability }
          end
        end
      end

      def build_authorizations(auth_results)
        auth_results.map do |resource_type, id_authorizations|
          Gkg::V1::ResourceAuthorization.new(
            resource_type: resource_type,
            authorized: id_authorizations.transform_keys(&:to_i)
          )
        end
      end

      def measure_grpc(method)
        start = ::Gitlab::Metrics::System.monotonic_time
        result = yield
        status = 'ok'
        result
      rescue StandardError
        status = 'error'
        raise
      ensure
        duration = ::Gitlab::Metrics::System.monotonic_time - start
        request_metrics.observe_grpc_duration(method, status || 'error', duration)
      end

      def redaction_metrics_observer
        ->(total:, filtered:, duration:) {
          request_metrics.observe_redaction_duration(duration)
          request_metrics.observe_redaction_batch_size(total) if total > 0
          request_metrics.observe_redaction_filtered(filtered) if filtered > 0
        }
      end

      def request_metrics
        ::Gitlab::Metrics::KnowledgeGraph::Request
      end

      def handle_grpc_error(rpc_name, error, extra = {})
        request_metrics.increment_grpc_error(rpc_name, error.code.to_s)
        log_error(rpc_name, **extra.merge(error: error.message, grpc_code: error.code))
        raise ConnectionError, "#{rpc_name} failed: #{error.message} (#{error.code})"
      end

      def safe_json_parse(json_string)
        return {} if json_string.blank?

        result = ::Gitlab::Json.safe_parse(json_string)
        return result if result

        log_error('json_parse', input_truncated: json_string.truncate(200))
        {}
      end

      def cluster_status_to_string(status)
        case status
        when :CLUSTER_STATUS_HEALTHY then 'healthy'
        when :CLUSTER_STATUS_DEGRADED then 'degraded'
        when :CLUSTER_STATUS_UNHEALTHY then 'unhealthy'
        else 'unknown'
        end
      end

      def component_to_hash(component)
        {
          name: component.name,
          status: cluster_status_to_string(component.status),
          replicas: {
            ready: component.replicas&.ready || 0,
            desired: component.replicas&.desired || 0
          },
          metrics: component.metrics.to_h
        }
      end

      def map_structured_schema(structured)
        {
          schema_version: structured.schema_version,
          domains: structured.domains.map { |d| schema_domain_to_hash(d) },
          nodes: structured.nodes.map { |n| schema_node_to_hash(n) },
          edges: structured.edges.map { |e| schema_edge_to_hash(e) }
        }
      end

      def schema_domain_to_hash(domain)
        {
          name: domain.name,
          description: domain.description,
          node_names: domain.node_names.to_a
        }
      end

      def schema_node_to_hash(node)
        hash = {
          name: node.name,
          domain: node.domain,
          description: node.description,
          primary_key: node.primary_key,
          label_field: node.label_field
        }

        if node.properties.any?
          hash[:properties] = node.properties.map { |p| schema_property_to_hash(p) }
          hash[:style] = { size: node.style&.size || 30, color: node.style&.color || '#64748B' }
          hash[:outgoing_edges] = node.outgoing_edges.to_a
          hash[:incoming_edges] = node.incoming_edges.to_a
        end

        hash
      end

      def schema_property_to_hash(property)
        {
          name: property.name,
          data_type: property.data_type,
          nullable: property.nullable,
          enum_values: property.enum_values.to_a
        }
      end

      def schema_edge_to_hash(edge)
        {
          name: edge.name,
          description: edge.description,
          variants: edge.variants.map { |v| { source_type: v.source_type, target_type: v.target_type } }
        }
      end

      def logger
        @logger ||= ::Gitlab::KnowledgeGraph::Logger.build
      end

      def log_error(rpc_name, **payload)
        logger.error(
          build_structured_payload(
            **payload.merge(
              message: "KnowledgeGraph::GrpcClient #{rpc_name} failed"
            )
          )
        )
      end
    end
  end
end
