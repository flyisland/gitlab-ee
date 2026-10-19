# frozen_string_literal: true

module EE
  module Gitlab
    module Workhorse
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end

      ORBIT_DEFAULT_TIMEOUT_SECONDS = 30

      module ClassMethods
        def send_orbit_query(**query_args)
          [
            ::Gitlab::Workhorse::SEND_DATA_HEADER,
            "orbit-query:#{encode(orbit_query_params(**query_args))}"
          ]
        end

        def orbit_query_params(
          query:, user:, format:, query_type: :raw, mcp_id: nil,
          request_context: ::Analytics::KnowledgeGraph::RequestContext.new
        )
          ::Analytics::KnowledgeGraph::GoverningNamespaceGuard.ensure_selected!(user)

          endpoint = ::Analytics::KnowledgeGraph::GrpcClient.configured_endpoint
          secure = ::Analytics::KnowledgeGraph::GrpcClient.secure_channel?(endpoint)

          headers = ::Analytics::KnowledgeGraph::GrpcClient.outgoing_headers
          headers['x-client-user-agent'] = request_context.user_agent if request_context.user_agent.present?

          if secure || ::Analytics::KnowledgeGraph::GrpcClient.private_address?(endpoint)
            jwt = ::Analytics::KnowledgeGraph::JwtAuth.generate_token(user: user, request_context: request_context)
            headers = headers.merge('authorization' => "Bearer #{jwt}") if jwt
          end

          params = {
            'GkgServer' => {
              'address' => endpoint,
              'tls' => secure,
              'headers' => headers
            },
            'Query' => query,
            'Language' => ::Analytics::KnowledgeGraph.gql_enabled_for?(user) ? 'gql' : 'json',
            'Format' => format.to_s,
            'TimeoutSeconds' => orbit_timeout_seconds
          }
          params['QueryType'] = query_type.to_s unless query_type.to_s == 'raw'
          params['McpId'] = mcp_id unless mcp_id.nil?

          client_ip = ::Gitlab::IpAddressState.current
          params['ClientIp'] = client_ip if client_ip.present?
          params
        end

        def orbit_timeout_seconds
          ::Gitlab.config.knowledge_graph.streaming_timeout_seconds
        rescue ::Gitlab::Configs::MissingConfig
          ENV.fetch('KNOWLEDGE_GRAPH_STREAMING_TIMEOUT', ORBIT_DEFAULT_TIMEOUT_SECONDS).to_i
        end
      end
    end
  end
end
