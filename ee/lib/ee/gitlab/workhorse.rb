# frozen_string_literal: true

module EE
  module Gitlab
    module Workhorse
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end

      ORBIT_DEFAULT_TIMEOUT_SECONDS = 30

      VALID_SOURCE_TYPES = [
        ::Analytics::KnowledgeGraph::SourceType::FRONTEND,
        ::Analytics::KnowledgeGraph::SourceType::DWS,
        ::Analytics::KnowledgeGraph::SourceType::MCP,
        ::Analytics::KnowledgeGraph::SourceType::CORE,
        ::Analytics::KnowledgeGraph::SourceType::REST
      ].freeze

      module ClassMethods
        def send_orbit_query(query:, user:, format:, source_type:, mcp_id: nil)
          endpoint = ::Analytics::KnowledgeGraph::GrpcClient.configured_endpoint
          secure = ::Analytics::KnowledgeGraph::GrpcClient.secure_channel?(endpoint)
          private_addr = ::Analytics::KnowledgeGraph::GrpcClient.private_address?(endpoint)
          jwt = if secure || private_addr
                  ::Analytics::KnowledgeGraph::JwtAuth.generate_token(
                    user: user,
                    source_type: validated_source_type(source_type)
                  )
                end

          params = {
            'GkgServer' => {
              'address' => endpoint,
              'jwt' => jwt,
              'tls' => secure
            },
            'Query' => query,
            'Format' => format.to_s,
            'TimeoutSeconds' => orbit_timeout_seconds
          }
          params['McpId'] = mcp_id unless mcp_id.nil?

          [
            ::Gitlab::Workhorse::SEND_DATA_HEADER,
            "orbit-query:#{encode(params)}"
          ]
        end

        def orbit_timeout_seconds
          ::Gitlab.config.knowledge_graph.streaming_timeout_seconds
        rescue GitlabSettings::MissingSetting
          ENV.fetch('KNOWLEDGE_GRAPH_STREAMING_TIMEOUT', ORBIT_DEFAULT_TIMEOUT_SECONDS).to_i
        end

        private

        def validated_source_type(source_type)
          return source_type if VALID_SOURCE_TYPES.include?(source_type)

          ::Gitlab::AppLogger.warn(
            "Invalid source_type for Orbit query: #{source_type.inspect}, falling back to 'rest'"
          )

          ::Analytics::KnowledgeGraph::SourceType::REST
        end
      end
    end
  end
end
