# frozen_string_literal: true

module API
  module Orbit
    module McpHandlers
      class Base
        WorkhorseSendData = Struct.new(:header_name, :header_value)

        attr_reader :access_token, :current_user, :params, :grpc_client, :mcp_request_id, :source_type

        def initialize(params, access_token, current_user, source_type:, grpc_client: nil, mcp_request_id: nil)
          @params = params
          @access_token = access_token
          @current_user = current_user
          @grpc_client = grpc_client || ::Analytics::KnowledgeGraph::GrpcClient.new
          @mcp_request_id = mcp_request_id
          @source_type = source_type
        end

        def invoke
          raise NoMethodError
        end
      end
    end
  end
end
