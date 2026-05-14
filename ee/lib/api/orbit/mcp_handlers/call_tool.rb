# frozen_string_literal: true

module API
  module Orbit
    module McpHandlers
      class CallTool < Base
        # TODO: Dynamically fetch from GKG ListTools gRPC instead of hardcoding.
        KNOWN_TOOLS = %w[query_graph get_graph_schema].freeze

        def invoke
          tool_name = params[:name]
          arguments = params[:arguments] || {}

          raise ArgumentError, "Missing required parameter 'name'" if tool_name.blank?
          raise ArgumentError, "Arguments must be a Hash" unless arguments.is_a?(Hash)
          raise ArgumentError, "Unknown tool: #{tool_name}" unless KNOWN_TOOLS.include?(tool_name)

          result = dispatch_tool(tool_name, arguments)

          return result if result.is_a?(WorkhorseSendData)

          format_success(result)
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          log_error('connection_error', e)
          raise ::API::Orbit::Mcp::InternalError, e.message
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ExecutionError => e
          log_error('execution_error', e)
          format_error(e.message)
        rescue ::Analytics::KnowledgeGraph::GrpcClient::StreamError => e
          log_error('stream_error', e)
          raise ::API::Orbit::Mcp::InternalError, e.message
        end

        private

        def dispatch_tool(tool_name, arguments)
          format = extract_format(arguments)

          case tool_name
          when 'query_graph'
            query = arguments['query'] || arguments[:query]
            query = query.to_json unless query.is_a?(String)
            WorkhorseSendData.new(*::Gitlab::Workhorse.send_orbit_query(
              query: query,
              user: current_user,
              format: format,
              mcp_id: mcp_request_id,
              source_type: source_type
            ))
          when 'get_graph_schema'
            grpc_client.get_graph_schema(
              expand_nodes: arguments['expand_nodes'] || arguments[:expand_nodes] || [],
              format: format,
              user: current_user,
              source_type: source_type
            )
          end
        end

        def extract_format(arguments)
          raw_format = arguments['format'] || arguments[:format]
          raw_format&.to_sym == :raw ? :raw : :llm
        end

        def format_success(result)
          {
            content: [{ type: 'text', text: result.to_json }],
            isError: false
          }
        end

        def format_error(message)
          {
            content: [{ type: 'text', text: message }],
            isError: true
          }
        end

        def log_error(type, error)
          ::Gitlab::KnowledgeGraph::Logger.build.error(
            message: "MCP Orbit call_tool #{type}",
            error: error.message,
            tool_name: params[:name]
          )
        end
      end
    end
  end
end
