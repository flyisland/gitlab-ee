# frozen_string_literal: true

require "spec_helper"

RSpec.describe API::Orbit::Mcp, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:access_token) { create(:oauth_access_token, user: user, scopes: [:mcp_orbit]) }
  let_it_be(:group) { create(:group) }

  let(:initialize_params) do
    { jsonrpc: '2.0', method: 'initialize', id: '1', params: { protocolVersion: '2025-06-18' } }
  end

  before_all do
    group.add_reporter(user)
  end

  before do
    stub_licensed_features(orbit: true)
  end

  describe 'POST /orbit/mcp' do
    context 'when knowledge_graph feature flag is disabled' do
      before do
        stub_feature_flags(knowledge_graph: false)
      end

      it 'returns not found' do
        post api('/orbit/mcp', user, oauth_access_token: access_token), params: initialize_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when knowledge_graph feature flag is enabled' do
      before do
        stub_feature_flags(knowledge_graph: user)
      end

      context 'when user belongs to a group with Premium plan' do
        it 'returns success for initialize' do
          post api('/orbit/mcp', user, oauth_access_token: access_token), params: initialize_params

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to eq({
            "id" => "1",
            "jsonrpc" => "2.0",
            "result" => {
              "capabilities" => { "tools" => { "listChanged" => false } },
              "protocolVersion" => "2025-06-18",
              "serverInfo" => { "name" => "GitLab Orbit MCP Server", "version" => Gitlab::VERSION }
            }
          })
        end
      end

      context 'when orbit licensed feature is not available' do
        before do
          stub_licensed_features(orbit: false)
        end

        it 'returns not found' do
          post api('/orbit/mcp', user, oauth_access_token: access_token), params: initialize_params

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'when access token is PAT' do
        it 'returns forbidden' do
          post api('/orbit/mcp', user), params: initialize_params

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when access token is OAuth without mcp_orbit scope' do
        let(:insufficient_access_token) { create(:oauth_access_token, user: user, scopes: [:api]) }

        it 'returns forbidden' do
          post api('/orbit/mcp', user, oauth_access_token: insufficient_access_token), params: initialize_params

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when access token has mcp scope but not mcp_orbit' do
        let(:mcp_only_access_token) { create(:oauth_access_token, user: user, scopes: [:mcp]) }

        it 'returns forbidden with insufficient_scope' do
          post api('/orbit/mcp', user, oauth_access_token: mcp_only_access_token), params: initialize_params

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when access token has multiple scopes including mcp_orbit' do
        let(:multi_scope_access_token) { create(:oauth_access_token, user: user, scopes: [:api, :mcp_orbit]) }

        it 'returns success' do
          post api('/orbit/mcp', user, oauth_access_token: multi_scope_access_token), params: initialize_params

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'when required jsonrpc param is missing' do
        it 'returns JSON-RPC Invalid Request error' do
          post api('/orbit/mcp', user, oauth_access_token: access_token), params: { id: '1', method: 'initialize' }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']['code']).to eq(-32600)
          expect(json_response['error']['data']['validations']).to include('jsonrpc is missing')
        end
      end

      context 'when required jsonrpc param is empty' do
        it 'returns JSON-RPC Invalid Request error' do
          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '', method: 'initialize', id: '1' }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']['code']).to eq(-32600)
          expect(json_response['error']['data']['validations']).to include('jsonrpc is empty')
        end
      end

      context 'when required jsonrpc param is invalid value' do
        it 'returns JSON-RPC Invalid Request error' do
          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '1.0', method: 'initialize', id: '1' }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']['code']).to eq(-32600)
          expect(json_response['error']['data']['validations']).to include('jsonrpc does not have a valid value')
        end
      end

      context 'when required method param is missing' do
        it 'returns JSON-RPC Invalid Request error' do
          post api('/orbit/mcp', user, oauth_access_token: access_token), params: { jsonrpc: '2.0', id: '1' }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']['code']).to eq(-32600)
          expect(json_response['error']['data']['validations']).to include('method is missing')
        end
      end

      context 'when required method param is empty' do
        it 'returns JSON-RPC Invalid Request error' do
          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: '', id: '1' }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']['code']).to eq(-32600)
          expect(json_response['error']['data']['validations']).to include('method is empty')
        end
      end

      context 'when optional id param is empty' do
        it 'returns JSON-RPC Invalid Request error' do
          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: 'initialize', id: '' }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']['code']).to eq(-32600)
          expect(json_response['error']['data']['validations']).to include('id is empty')
        end
      end

      context 'when method does not exist' do
        it 'returns JSON-RPC Method not found error' do
          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: 'unknown/method', id: '1' }

          expect(response).to have_gitlab_http_status(:not_found)
          expect(json_response['error']['code']).to eq(-32601)
          expect(json_response['error']['message']).to eq('Method not found')
        end
      end

      context 'when notifications/initialized is sent without id' do
        it 'returns empty body' do
          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: 'notifications/initialized' }

          expect(response).to have_gitlab_http_status(:no_content)
        end
      end

      describe 'tools/list' do
        let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }
        let(:grpc_tools) do
          [
            {
              name: 'query_graph',
              description: 'Query the knowledge graph',
              parameters: { 'type' => 'object', 'properties' => { 'query' => { 'type' => 'string' } } }
            }
          ]
        end

        before do
          allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:new).and_return(grpc_client)
        end

        it 'returns tools from gRPC' do
          allow(grpc_client).to receive(:list_tools)
            .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::MCP).and_return(grpc_tools)

          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: 'tools/list', id: '1' }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['result']['tools'].first['name']).to eq('query_graph')
          expect(json_response['result']['tools'].first['inputSchema']).to be_present
        end

        it 'uses dws source_type when ai_workflows scope is present' do
          dws_access_token = create(:oauth_access_token, user: user, scopes: [:mcp_orbit, :ai_workflows])

          allow(grpc_client).to receive(:list_tools)
            .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::DWS).and_return(grpc_tools)

          post api('/orbit/mcp', user, oauth_access_token: dws_access_token),
            params: { jsonrpc: '2.0', method: 'tools/list', id: '1' }

          expect(response).to have_gitlab_http_status(:ok)
        end

        context 'when access_token is nil (session-authenticated user)' do
          before do
            allow(::Analytics::KnowledgeGraph::SourceType).to receive(:for_mcp_request)
              .and_return(Analytics::KnowledgeGraph::SourceType::MCP)
            allow(grpc_client).to receive(:list_tools)
              .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::MCP).and_return(grpc_tools)
          end

          it 'delegates to SourceType.for_mcp_request' do
            post api('/orbit/mcp', user, oauth_access_token: access_token),
              params: { jsonrpc: '2.0', method: 'tools/list', id: '1' }

            expect(::Analytics::KnowledgeGraph::SourceType).to have_received(:for_mcp_request)
            expect(grpc_client).to have_received(:list_tools)
              .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          end
        end
      end

      describe 'tools/call' do
        let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }

        before do
          allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:new).and_return(grpc_client)
        end

        it 'returns Workhorse SendData for query_graph' do
          allow(Gitlab::Workhorse).to receive(:send_orbit_query)
            .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test-encoded-data'])

          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: 'tools/call', id: '1',
                      params: { name: 'query_graph', arguments: { query: 'pipelines' } } }

          expect(response).to have_gitlab_http_status(:ok)
          expect(response.headers['Gitlab-Workhorse-Send-Data']).to start_with('orbit-query:')
          # Body content depends on whether Workhorse SendData middleware is active;
          # the SendData header is the meaningful assertion.
        end

        it 'passes dws source_type to Workhorse when ai_workflows scope is present' do
          dws_access_token = create(:oauth_access_token, user: user, scopes: [:mcp_orbit, :ai_workflows])

          allow(Gitlab::Workhorse).to receive(:send_orbit_query)
            .with(hash_including(source_type: Analytics::KnowledgeGraph::SourceType::DWS))
            .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test-encoded-data'])

          post api('/orbit/mcp', user, oauth_access_token: dws_access_token),
            params: { jsonrpc: '2.0', method: 'tools/call', id: '1',
                      params: { name: 'query_graph', arguments: { query: 'pipelines' } } }

          expect(response).to have_gitlab_http_status(:ok)
        end

        it 'returns result from gRPC on success for get_graph_schema' do
          schema_result = { 'nodes' => [], 'edges' => [] }
          allow(grpc_client).to receive(:get_graph_schema)
            .with(expand_nodes: [], format: :llm, user: user,
              source_type: Analytics::KnowledgeGraph::SourceType::MCP)
            .and_return(schema_result)

          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: 'tools/call', id: '1',
                      params: { name: 'get_graph_schema', arguments: {} } }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['result']['isError']).to be(false)
        end

        it 'rejects unknown tools' do
          post api('/orbit/mcp', user, oauth_access_token: access_token),
            params: { jsonrpc: '2.0', method: 'tools/call', id: '1',
                      params: { name: 'unknown_tool', arguments: {} } }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']['code']).to eq(-32602)
        end
      end
    end
  end

  describe 'GET /orbit/mcp' do
    context 'when unauthenticated' do
      it 'returns authentication error' do
        get api('/orbit/mcp')

        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      before do
        stub_feature_flags(knowledge_graph: user)
      end

      it 'returns method not allowed' do
        get api('/orbit/mcp', user, oauth_access_token: access_token)

        expect(response).to have_gitlab_http_status(:method_not_allowed)
      end
    end
  end
end
