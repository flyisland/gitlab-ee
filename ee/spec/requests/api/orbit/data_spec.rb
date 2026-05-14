# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Orbit::Data, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }

  before do
    stub_feature_flags(knowledge_graph: true)
  end

  shared_examples 'requires authentication' do
    context 'when not authenticated' do
      it 'returns 401' do
        send_request(user: nil)

        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end
  end

  shared_examples 'requires knowledge_graph feature flag' do
    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(knowledge_graph: false)
      end

      it 'returns 404' do
        send_request

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'POST /orbit/query' do
    include WorkhorseHelpers

    let(:query) { { nodes: ['MergeRequest'] } }
    let(:params) { { query: query } }
    let(:endpoint) { 'localhost:50054' }
    let(:jwt_token) { 'test-jwt-token' }

    before do
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:configured_endpoint).and_return(endpoint)
      allow(Analytics::KnowledgeGraph::SourceType).to receive(:for_orbit_request)
        .and_return(Analytics::KnowledgeGraph::SourceType::REST)
      allow(Analytics::KnowledgeGraph::JwtAuth).to receive(:generate_token)
        .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::REST).and_return(jwt_token)
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:secure_channel?).with(endpoint).and_return(false)
    end

    def send_request(user: self.user, request_params: params)
      post api('/orbit/query', user), params: request_params
    end

    include_examples 'requires authentication'
    include_examples 'requires knowledge_graph feature flag'

    it_behaves_like 'authorizing granular token permissions', :read_knowledge_graph do
      let(:boundary_object) { :user }
      let(:request) do
        post api('/orbit/query', personal_access_token: pat), params: params
      end
    end

    context 'when authenticated' do
      it 'returns a Workhorse SendData response' do
        send_request

        expect(response).to have_gitlab_http_status(:ok)

        type, params = workhorse_send_data
        expect(type).to eq('orbit-query')
        expect(params).to include(
          'GkgServer' => {
            'address' => endpoint,
            'jwt' => jwt_token,
            'tls' => false
          },
          'Query' => query.to_json,
          'Format' => 'raw'
        )
      end

      it 'supports llm response format' do
        send_request(request_params: params.merge(response_format: 'llm'))

        expect(response).to have_gitlab_http_status(:ok)

        _, params = workhorse_send_data
        expect(params['Format']).to eq('llm')
      end

      context 'when query param is missing' do
        it 'returns 400' do
          send_request(request_params: {})

          expect(response).to have_gitlab_http_status(:bad_request)
        end
      end

      context 'when JWT generation raises AuthorizationError' do
        before do
          allow(Analytics::KnowledgeGraph::JwtAuth).to receive(:generate_token)
            .and_raise(Analytics::KnowledgeGraph::GrpcClient::AuthorizationError, 'JWT generation failed')
        end

        it 'returns 503' do
          send_request

          expect(response).to have_gitlab_http_status(:service_unavailable)
        end
      end
    end
  end

  describe 'GET /orbit/schema' do
    let(:schema_result) do
      { schema_version: '1.0', domains: [], nodes: [], edges: [] }
    end

    let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }

    before do
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:new).and_return(grpc_client)
      allow(grpc_client).to receive(:get_graph_schema).and_return(schema_result)
    end

    def send_request(user: self.user, request_params: {})
      get api('/orbit/schema', user), params: request_params
    end

    include_examples 'requires authentication'
    include_examples 'requires knowledge_graph feature flag'

    it_behaves_like 'authorizing granular token permissions', :read_knowledge_graph do
      let(:boundary_object) { :user }
      let(:request) { get api('/orbit/schema', personal_access_token: pat) }
    end

    context 'when authenticated' do
      it 'returns the schema' do
        send_request

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to include('schema_version' => '1.0')
      end

      it 'passes expand nodes to the grpc client' do
        send_request(request_params: { expand: 'MergeRequest, Issue' })

        expect(grpc_client).to have_received(:get_graph_schema).with(
          user: user,
          source_type: Analytics::KnowledgeGraph::SourceType::REST,
          expand_nodes: %w[MergeRequest Issue],
          format: :raw
        )
      end

      it 'supports llm response format' do
        send_request(request_params: { response_format: 'llm' })

        expect(grpc_client).to have_received(:get_graph_schema).with(
          hash_including(format: :llm)
        )
      end

      context 'when using an OAuth access token' do
        let(:oauth_token) { create(:oauth_access_token, user: user, scopes: [:api]) }

        before do
          allow(::Analytics::KnowledgeGraph::SourceType).to receive(:for_orbit_request)
            .with(hash_including(oauth_access_token: oauth_token))
            .and_return(Analytics::KnowledgeGraph::SourceType::REST)
        end

        it 'passes the OAuth token to for_orbit_request' do
          get api('/orbit/schema', user, oauth_access_token: oauth_token)

          expect(::Analytics::KnowledgeGraph::SourceType).to have_received(:for_orbit_request)
            .with(hash_including(oauth_access_token: oauth_token))
        end
      end

      context 'when grpc client raises ConnectionError' do
        before do
          allow(grpc_client).to receive(:get_graph_schema)
            .and_raise(Analytics::KnowledgeGraph::GrpcClient::ConnectionError, 'unavailable')
        end

        it 'returns 503' do
          send_request

          expect(response).to have_gitlab_http_status(:service_unavailable)
        end
      end
    end
  end

  describe 'GET /orbit/status' do
    let(:status_result) do
      { status: 'healthy', timestamp: '2026-01-01', version: '1.0', components: [] }
    end

    let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }

    before do
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:new).and_return(grpc_client)
      allow(grpc_client).to receive(:get_cluster_health).and_return(status_result)
    end

    def send_request(user: self.user, request_params: {})
      get api('/orbit/status', user), params: request_params
    end

    include_examples 'requires authentication'
    include_examples 'requires knowledge_graph feature flag'

    it_behaves_like 'authorizing granular token permissions', :read_knowledge_graph do
      let(:boundary_object) { :user }
      let(:request) { get api('/orbit/status', personal_access_token: pat) }
    end

    context 'when authenticated' do
      it 'returns cluster health' do
        send_request

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to include('status' => 'healthy')
      end

      it 'supports llm response format' do
        send_request(request_params: { response_format: 'llm' })

        expect(grpc_client).to have_received(:get_cluster_health).with(
          hash_including(format: :llm, source_type: Analytics::KnowledgeGraph::SourceType::REST)
        )
      end

      context 'when grpc service is unreachable' do
        before do
          allow(grpc_client).to receive(:get_cluster_health)
            .and_return({ status: 'unknown', error: 'Service unreachable' })
        end

        it 'returns 200 with error status' do
          send_request

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to include('status' => 'unknown', 'error' => 'Service unreachable')
        end
      end
    end
  end

  describe 'GET /orbit/tools' do
    let(:tools_result) do
      [{ name: 'query', description: 'Execute a query', parameters: {} }]
    end

    let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }

    before do
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:new).and_return(grpc_client)
      allow(grpc_client).to receive(:list_tools).and_return(tools_result)
      allow(Analytics::KnowledgeGraph::SourceType).to receive(:for_orbit_request)
        .and_return(Analytics::KnowledgeGraph::SourceType::REST)
    end

    def send_request(user: self.user)
      get api('/orbit/tools', user)
    end

    include_examples 'requires authentication'
    include_examples 'requires knowledge_graph feature flag'

    it_behaves_like 'authorizing granular token permissions', :read_knowledge_graph do
      let(:boundary_object) { :user }
      let(:request) { get api('/orbit/tools', personal_access_token: pat) }
    end

    context 'when authenticated' do
      it 'returns available tools' do
        send_request

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.first).to include('name' => 'query')
      end

      it 'passes source_type to grpc client' do
        send_request

        expect(grpc_client).to have_received(:list_tools)
          .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::REST)
      end

      context 'when grpc client raises ConnectionError' do
        before do
          allow(grpc_client).to receive(:list_tools)
            .and_raise(Analytics::KnowledgeGraph::GrpcClient::ConnectionError, 'unavailable')
        end

        it 'returns 503' do
          send_request

          expect(response).to have_gitlab_http_status(:service_unavailable)
        end
      end
    end
  end
end
