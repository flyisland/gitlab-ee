# frozen_string_literal: true

module API
  module Orbit
    class Data < ::API::Base
      include ::API::Helpers::HeadersHelpers
      include APIGuard

      feature_category :knowledge_graph
      urgency :low

      before do
        authenticate!
        not_found! unless Feature.enabled?(:knowledge_graph, current_user)
      end

      helpers do
        def source_type
          @source_type ||= ::Analytics::KnowledgeGraph::SourceType.for_orbit_request(
            request: request,
            oauth_access_token: access_token.is_a?(OauthAccessToken) ? access_token : nil
          )
        end

        def orbit_response_format
          params[:response_format].to_sym == :llm ? :llm : :raw
        end

        def grpc_client
          @grpc_client ||= ::Analytics::KnowledgeGraph::GrpcClient.new
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
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        post :query do
          status 200
          header(*Gitlab::Workhorse.send_orbit_query(
            query: declared_params[:query].to_json,
            user: current_user,
            format: orbit_response_format,
            source_type: source_type
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
            source_type: source_type,
            expand_nodes: expand_nodes,
            format: orbit_response_format
          )
          present result
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
            source_type: source_type,
            format: orbit_response_format
          )
          present result
        end

        desc 'List all tools' do
          detail 'Lists all available Orbit operations.'
          tags 'knowledge_graph'
          hidden true
          success code: 200
        end
        route_setting :authorization, permissions: :read_knowledge_graph, boundary_type: :user
        get :tools do
          result = grpc_client.list_tools(user: current_user, source_type: source_type)
          present result
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          service_unavailable!(e.message)
        end
      end
    end
  end
end
