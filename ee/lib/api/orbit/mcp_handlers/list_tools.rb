# frozen_string_literal: true

module API
  module Orbit
    module McpHandlers
      class ListTools < Base
        def invoke
          tools = grpc_client.list_tools(user: current_user, source_type: source_type)

          { tools: tools.map { |tool| format_tool(tool) } }
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          ::Gitlab::KnowledgeGraph::Logger.build.error(message: 'list_tools connection error', error: e.message)
          { tools: [] }
        end

        private

        def format_tool(tool)
          {
            name: tool[:name],
            description: tool[:description],
            inputSchema: tool[:parameters]
          }
        end
      end
    end
  end
end
