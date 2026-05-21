# frozen_string_literal: true

module API
  module Orbit
    class Data < ::API::Base
      include ::API::Helpers::HeadersHelpers
      include APIGuard

      feature_category :knowledge_graph
      urgency :low

      # Although this API endpoint responds to POST requests, it is a read-only operation
      allow_access_with_scope :read_api

      before do
        authenticate!
        not_found! unless ::Analytics::KnowledgeGraph::OrbitLicense.feature_flag_enabled?(current_user)
        forbidden! unless ::Analytics::KnowledgeGraph::OrbitLicense.available_for?(current_user)
      end

      helpers do
        def source_type(frontend_subtype: nil)
          ::Analytics::KnowledgeGraph::SourceType.for_orbit_request(
            request: request,
            oauth_access_token: access_token.is_a?(OauthAccessToken) ? access_token : nil,
            frontend_subtype: frontend_subtype
          )
        end

        def orbit_response_format
          params[:response_format].to_sym == :llm ? :llm : :raw
        end

        def grpc_client
          @grpc_client ||= ::Analytics::KnowledgeGraph::GrpcClient.new
        end

        include ::Analytics::Orbit::TargetResolver
        include ::Analytics::Orbit::CommandInterceptor

        def require_enabled_namespaces!
          context = ::Analytics::KnowledgeGraph::AuthorizationContext.new(current_user)
          forbidden!('No Knowledge Graph enabled namespaces available') unless context.has_enabled_namespaces?
        end

        def orbit_request_context(resolved_source_type = source_type)
          ::Analytics::KnowledgeGraph::RequestContext.new(
            source_type: resolved_source_type,
            session_id: request.headers['X-Duo-Workflow-Session-Id'],
            user_agent: request.user_agent
          )
        end

        def invoke_agent_command(command_name, parameters)
          rate_limit_agent_command!(command_name)

          format = orbit_command_format(parameters)
          intercepted = intercept_orbit_command(
            command_name,
            arguments: parameters,
            format: format,
            user: current_user,
            request_context: orbit_request_context
          )

          return agent_command_response(workhorse_send_data: intercepted.workhorse_send_data) if intercepted.workhorse?
          return agent_command_response(body: intercepted.result) if intercepted.handled?

          result = grpc_client.invoke_agent_command(
            command_name: command_name,
            parameters: parameters,
            user: current_user,
            request_context: orbit_request_context
          )

          agent_command_response(body: result)
        rescue ::Analytics::Orbit::CommandInterceptor::EnabledNamespacesRequiredError => e
          forbidden!(e.message)
        rescue ::Analytics::Orbit::CommandInterceptor::CommandError => e
          bad_request!(e.message)
        end

        def agent_command_response(body: nil, workhorse_send_data: nil)
          ::Analytics::Orbit::CommandInterceptor::CommandResponse.new(
            body: body,
            workhorse_send_data: workhorse_send_data
          )
        end

        def present_agent_schema_command(command_name)
          result = invoke_agent_command(command_name, { 'format' => params[:response_format] })

          present result.body
        end

        def rate_limit_agent_command!(command_name)
          check_rate_limit!(:orbit_query, scope: current_user) if command_name == 'query_graph'
        end
      end

      rescue_from ::Analytics::KnowledgeGraph::GrpcClient::AuthorizationError do
        error!('503 Service Unavailable', 503)
      end

      namespace :orbit do
        desc 'Execute a query' do
          detail 'Executes a query against the Knowledge Graph gRPC service.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        params do
          requires :query, type: Hash, desc: 'Query DSL object'
          optional :response_format, type: String, values: %w[raw llm],
            default: 'raw', desc: 'Response format: raw or llm'
          optional :source_type, type: String, desc: 'Optional frontend source subtype (e.g. code_intelligence)'
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        post :query do
          check_rate_limit!(:orbit_query, scope: current_user)
          require_enabled_namespaces!

          status 200
          header(*Gitlab::Workhorse.send_orbit_query(
            query: declared_params[:query].to_json,
            user: current_user,
            format: orbit_response_format,
            request_context: orbit_request_context(source_type(frontend_subtype: params[:source_type]))
          ))
          body ''
        end

        desc 'Retrieve the schema' do
          detail 'Retrieves the Knowledge Graph schema.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        params do
          optional :expand, type: String,
            desc: 'Comma-separated node names to expand'
          optional :response_format, type: String, values: %w[raw llm],
            default: 'raw', desc: 'Response format: raw or llm'
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        get :schema do
          expand_nodes = params[:expand]&.split(',')&.map(&:strip) || []
          result = grpc_client.get_graph_schema(
            user: current_user,
            expand_nodes: expand_nodes,
            format: orbit_response_format,
            request_context: orbit_request_context
          )
          present result
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          service_unavailable!(e.message)
        end

        desc 'Retrieve the query DSL' do
          detail 'Retrieves the Knowledge Graph query DSL.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        params do
          optional :response_format, type: String, values: %w[raw llm],
            default: 'raw', desc: 'Response format: raw or llm'
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        get 'schema/dsl' do
          present_agent_schema_command('get_query_dsl')
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          service_unavailable!(e.message)
        end

        desc 'Retrieve response format guidance' do
          detail 'Retrieves guidance for formatting Knowledge Graph query responses.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        params do
          optional :response_format, type: String, values: %w[raw llm],
            default: 'raw', desc: 'Response format: raw or llm'
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        get 'schema/format' do
          present_agent_schema_command('get_response_format')
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          service_unavailable!(e.message)
        end

        # get_cluster_health catches GRPC::BadStatus internally and returns
        # { status: 'unknown', error: 'Service unreachable' } instead of raising.
        # A health endpoint reports what is broken rather than itself breaking,
        # so we always return 200 here unlike the other endpoints.
        desc 'Retrieve cluster health' do
          detail 'Retrieves cluster health and component status.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        params do
          optional :response_format, type: String, values: %w[raw llm],
            default: 'raw', desc: 'Response format: raw or llm'
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        get :status do
          result = grpc_client.get_cluster_health(
            user: current_user,
            format: orbit_response_format,
            request_context: orbit_request_context
          )
          present result
        end

        desc 'Retrieve graph status' do
          detail 'Returns indexing progress and entity counts for a namespace or project.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        params do
          optional :namespace_id, type: Integer, desc: 'Namespace (group) ID'
          optional :project_id, type: Integer, desc: 'Project ID'
          optional :full_path, type: String, desc: 'Full path of a project or group (e.g. gitlab-org/gitlab)'
          optional :response_format, type: String, values: %w[raw llm],
            default: 'raw', desc: 'Response format: raw or llm'
          exactly_one_of :namespace_id, :project_id, :full_path
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        get :graph_status do
          require_enabled_namespaces!

          context = resolve_graph_status_context(params)
          not_found!('Namespace') unless context

          is_project = context[:target].is_a?(Project)
          ability = is_project ? :read_project : :read_group
          not_found!('Namespace') unless can?(current_user, ability, context[:target])

          result = grpc_client.get_graph_status(
            user: current_user,
            traversal_path: context[:traversal_path],
            target_type: is_project ? :project : :group,
            format: orbit_response_format,
            request_context: orbit_request_context
          )
          present result
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          service_unavailable!(e.message)
        end

        desc 'List all tools' do
          detail 'Lists all available Orbit operations.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        get :tools do
          result = grpc_client.list_tools(user: current_user, request_context: orbit_request_context)
          visible_tool_names = ::API::Orbit::McpHandlers::ToolCatalog.visible_tool_names(current_user)
          result = result.select { |tool| visible_tool_names.include?(tool[:name]) }
          present result
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          service_unavailable!(e.message)
        end

        namespace :agent do
          desc 'List Orbit agent commands' do
            detail 'Lists Orbit commands that can be invoked through the agent command endpoint.'
            tags 'knowledge_graph'
            hidden true
            success code: 200
          end
          params do
            optional :command_names, type: String,
              desc: 'Comma-separated command names to describe. Omit or leave empty to list every command.'
            optional :response_format, type: String, values: %w[raw llm],
              default: 'raw', desc: 'Response format: raw or llm'
          end
          route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
          get 'commands' do
            result = grpc_client.list_agent_commands(
              user: current_user,
              command_names: normalize_orbit_command_names(params[:command_names]),
              format: orbit_response_format,
              request_context: orbit_request_context
            )

            present result
          rescue ::Analytics::Orbit::CommandInterceptor::CommandError => e
            bad_request!(e.message)
          rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
            service_unavailable!(e.message)
          end

          desc 'Invoke an Orbit agent command' do
            detail 'Invokes a command by name. Rails intercepts commands that require Rails-owned behavior.'
            tags 'knowledge_graph'
            hidden true
            success code: 200
          end
          params do
            requires :name, type: String, desc: 'Command name'
            optional :parameters, type: Hash, default: {}, desc: 'Command parameters'
          end
          route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
          post 'commands/:name' do
            parameters = declared_params[:parameters] || {}
            result = invoke_agent_command(params[:name], parameters)

            status 200

            if result.workhorse?
              header(*result.workhorse_send_data)
              body ''
            else
              present result.body
            end
          rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
            service_unavailable!(e.message)
          end
        end
      end
    end
  end
end
