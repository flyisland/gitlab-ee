# frozen_string_literal: true

module Resolvers
  module Analytics
    module Orbit
      module StatusResolvable
        include ::Analytics::Orbit::TargetResolver

        GRPC_ERROR_MESSAGE = 'Knowledge graph request failed'

        private

        def orbit_traversal_path
          build_graph_status_context(object)&.fetch(:traversal_path)
        end

        def request_orbit(traversal_paths)
          authorization_context = ::Analytics::KnowledgeGraph::AuthorizationContext.for(current_user)
          paths_in_scope = authorization_context.traversal_paths_in_scope(traversal_paths)
          return if paths_in_scope.empty?

          yield ::Analytics::KnowledgeGraph::GrpcClient.new, paths_in_scope, orbit_request_context
        rescue ::Analytics::KnowledgeGraph::GrpcClient::ConnectionError => e
          return if e.grpc_code == ::GRPC::Core::StatusCodes::UNIMPLEMENTED

          raise_resource_not_available_error! GRPC_ERROR_MESSAGE
        rescue ::Analytics::KnowledgeGraph::GrpcClient::AuthorizationError
          raise_resource_not_available_error! GRPC_ERROR_MESSAGE
        end

        def check_orbit_rate_limit!(rate_limit_key)
          return unless ::Gitlab::ApplicationRateLimiter.throttled?(rate_limit_key, scope: { user: current_user })

          raise_resource_not_available_error! ::Gitlab::ApplicationRateLimiter.throttled_error_message
        end

        def orbit_request_context
          request = context[:request]
          return ::Analytics::KnowledgeGraph::RequestContext.new unless request

          ::Analytics::KnowledgeGraph::RequestContext.from_request(
            request,
            source_type: ::Analytics::KnowledgeGraph::SourceType.for_orbit_request(request: request)
          )
        end
      end
    end
  end
end
