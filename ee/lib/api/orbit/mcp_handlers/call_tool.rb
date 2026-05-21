# frozen_string_literal: true

module API
  module Orbit
    module McpHandlers
      class CallTool < Base
        include ::Analytics::Orbit::TargetResolver
        include ::Analytics::Orbit::CommandInterceptor

        # TODO: Dynamically fetch from GKG ListTools gRPC instead of hardcoding.
        KNOWN_TOOLS = %w[query_graph get_graph_schema get_graph_status].freeze
        COMMAND_TOOLS = ToolCatalog::COMMAND_TOOL_NAMES

        def invoke
          tool_name = params[:name]
          arguments = params[:arguments] || {}

          raise ArgumentError, "Missing required parameter 'name'" if tool_name.blank?
          raise ArgumentError, "Arguments must be a Hash" unless arguments.is_a?(Hash)
          raise ArgumentError, "Unknown tool: #{tool_name}" unless (KNOWN_TOOLS + COMMAND_TOOLS).include?(tool_name)

          result = dispatch_tool(tool_name, arguments)

          return result if result.is_a?(WorkhorseSendData)
          return result if result.is_a?(Hash) && result[:isError]

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
          format = orbit_command_format(arguments) unless ToolCatalog::COMMAND_TOOL_NAMES.include?(tool_name)

          case tool_name
          when 'query_graph'
            dispatch_intercepted_command(tool_name, arguments, format: format)
          when 'get_graph_schema'
            dispatch_get_graph_schema(arguments, format: format)
          when 'get_graph_status'
            dispatch_get_graph_status(arguments, format: format)
          when 'list_commands'
            dispatch_list_commands(arguments)
          when 'invoke_command'
            dispatch_invoke_command(arguments)
          end
        end

        def dispatch_intercepted_command(command_name, arguments, format:)
          intercepted = intercept_orbit_command(
            command_name,
            arguments: arguments,
            format: format,
            user: current_user,
            mcp_request_id: mcp_request_id,
            request_context: request_context
          )

          return WorkhorseSendData.new(*intercepted.workhorse_send_data) if intercepted.workhorse?

          intercepted.result
        rescue ::Analytics::Orbit::CommandInterceptor::CommandError => e
          format_error(e.message)
        end

        def dispatch_get_graph_schema(arguments, format:)
          grpc_client.get_graph_schema(
            expand_nodes: arguments['expand_nodes'] || arguments[:expand_nodes] || [],
            format: format,
            user: current_user,
            request_context: request_context
          )
        end

        def dispatch_get_graph_status(arguments, format:)
          unless ::Analytics::KnowledgeGraph::AuthorizationContext.new(current_user).has_enabled_namespaces?
            return format_error('No Knowledge Graph enabled namespaces available')
          end

          context = resolve_graph_status_context(arguments.symbolize_keys)
          return format_error('Namespace not found') unless context

          is_project = context[:target].is_a?(Project)
          ability = is_project ? :read_project : :read_group
          return format_error('Namespace not found') unless Ability.allowed?(current_user, ability, context[:target])

          grpc_client.get_graph_status(
            user: current_user,
            traversal_path: context[:traversal_path],
            target_type: is_project ? :project : :group,
            format: format,
            request_context: request_context
          )
        end

        def dispatch_list_commands(arguments)
          format = orbit_command_format(arguments)
          grpc_client.list_agent_commands(
            user: current_user,
            command_names: normalize_orbit_command_names(arguments['command_names'] || arguments[:command_names]),
            format: format,
            request_context: request_context
          )
        rescue ::Analytics::Orbit::CommandInterceptor::CommandError => e
          format_error(e.message)
        end

        def dispatch_invoke_command(arguments)
          command_name, parameters = parse_invoke_command_arguments(arguments)
          command_format = orbit_command_format(parameters)

          intercepted = intercept_orbit_command(
            command_name,
            arguments: parameters,
            format: command_format,
            user: current_user,
            mcp_request_id: mcp_request_id,
            request_context: request_context
          )

          return WorkhorseSendData.new(*intercepted.workhorse_send_data) if intercepted.workhorse?
          return intercepted.result if intercepted.handled?

          grpc_client.invoke_agent_command(
            command_name: command_name,
            parameters: parameters,
            user: current_user,
            request_context: request_context
          )
        rescue ::Analytics::Orbit::CommandInterceptor::CommandError => e
          format_error(e.message)
        end

        def parse_invoke_command_arguments(arguments)
          args = arguments.stringify_keys
          unknown_keys = args.keys - %w[command_name parameters]
          unless unknown_keys.empty?
            raise ArgumentError,
              "Unknown top-level parameter(s) for invoke_command: #{unknown_keys.join(', ')}. " \
                "Put downstream command inputs inside 'parameters'."
          end

          command_name = args['command_name']
          raise ArgumentError, "Missing required parameter 'command_name'" if command_name.blank?

          parameters = args['parameters'] || {}
          raise ArgumentError, "'parameters' must be a Hash" unless parameters.is_a?(Hash)

          [command_name, parameters]
        end

        def format_success(result)
          text = result.is_a?(Hash) && result.key?(:formatted_text) ? result[:formatted_text].to_s : result.to_json
          {
            content: [{ type: 'text', text: text }],
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
