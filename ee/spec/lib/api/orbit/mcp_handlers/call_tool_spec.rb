# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Orbit::McpHandlers::CallTool, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:access_token) { create(:oauth_access_token, user: user, scopes: [:mcp_orbit]) }

  let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }
  let(:tool_name) { 'query_graph' }
  let(:arguments) { { 'query' => 'find pipelines' } }
  let(:params) { { name: tool_name, arguments: arguments } }

  subject(:handler) do
    described_class.new(
      params,
      access_token,
      user,
      grpc_client: grpc_client,
      source_type: Analytics::KnowledgeGraph::SourceType::MCP
    )
  end

  describe '#invoke' do
    context 'when query_graph tool is called' do
      let(:send_data_header) { 'Gitlab-Workhorse-Send-Data' }
      let(:send_data_value) { 'orbit-query:test-encoded-data' }

      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(query: 'find pipelines', user: user, format: :llm, mcp_id: nil,
            source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return([send_data_header, send_data_value])
      end

      it 'returns a WorkhorseSendData struct' do
        result = handler.invoke

        expect(result).to be_a(described_class::WorkhorseSendData)
        expect(result.header_name).to eq(send_data_header)
        expect(result.header_value).to eq(send_data_value)
      end
    end

    context 'when query_graph is called with format raw' do
      let(:arguments) { { 'query' => 'find pipelines', 'format' => 'raw' } }

      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(query: 'find pipelines', user: user, format: :raw, mcp_id: nil,
            source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'passes raw format to Workhorse' do
        result = handler.invoke

        expect(result).to be_a(described_class::WorkhorseSendData)
        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(format: :raw))
      end
    end

    context 'when query_graph is called without format' do
      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(query: 'find pipelines', user: user, format: :llm, mcp_id: nil,
            source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'defaults to llm format' do
        handler.invoke

        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(format: :llm))
      end
    end

    context 'when query_graph is called with a Hash query' do
      let(:arguments) { { 'query' => { 'query_type' => 'search', 'node' => { 'id' => 'n', 'entity' => 'Project' } } } }

      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(query: arguments['query'].to_json, user: user, format: :llm, mcp_id: nil,
            source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'serializes the Hash to JSON before passing to Workhorse' do
        result = handler.invoke

        expect(result).to be_a(described_class::WorkhorseSendData)
        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(query: arguments['query'].to_json))
      end
    end

    context 'when get_graph_schema tool execution succeeds' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => ['Pipeline'] } }
      let(:schema_result) { { 'nodes' => [{ 'name' => 'Pipeline' }], 'edges' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .with(expand_nodes: ['Pipeline'], format: :llm, user: user,
            source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return(schema_result)
      end

      it 'routes to get_graph_schema and returns result' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        parsed = Gitlab::Json.safe_parse(result[:content].first[:text])
        expect(parsed).to eq(schema_result)
      end
    end

    context 'when get_graph_schema is called with format raw' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => ['Pipeline'], 'format' => 'raw' } }
      let(:schema_result) { { 'nodes' => [{ 'name' => 'Pipeline' }], 'edges' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .with(expand_nodes: ['Pipeline'], format: :raw, user: user,
            source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return(schema_result)
      end

      it 'passes raw format to grpc_client' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        expect(grpc_client).to have_received(:get_graph_schema)
          .with(hash_including(format: :raw))
      end
    end

    context 'when tool name is unknown' do
      let(:params) { { name: 'unknown_tool', arguments: {} } }

      it 'raises ArgumentError' do
        expect { handler.invoke }.to raise_error(ArgumentError, /Unknown tool: unknown_tool/)
      end
    end

    context 'when tool name is missing' do
      let(:params) { { name: nil, arguments: {} } }

      it 'raises ArgumentError' do
        expect { handler.invoke }.to raise_error(ArgumentError)
      end
    end

    context 'when tool name is empty' do
      let(:params) { { name: '', arguments: {} } }

      it 'raises ArgumentError' do
        expect { handler.invoke }.to raise_error(ArgumentError)
      end
    end

    context 'when get_graph_schema raises ConnectionError' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::ConnectionError, 'connection refused')
      end

      it 'raises API::Orbit::Mcp::InternalError' do
        expect { handler.invoke }.to raise_error(API::Orbit::Mcp::InternalError, /connection refused/)
      end
    end

    context 'when get_graph_schema raises ExecutionError' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => ['BadNode'] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::ExecutionError, 'INVALID_NODE: BadNode')
      end

      it 'returns MCP error result with isError true' do
        result = handler.invoke

        expect(result[:isError]).to be(true)
        expect(result[:content]).to be_an(Array)
        expect(result[:content].first[:type]).to eq('text')
        expect(result[:content].first[:text]).to include('INVALID_NODE: BadNode')
      end
    end

    context 'when get_graph_schema raises StreamError' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::StreamError, 'Stream ended without result')
      end

      it 'raises API::Orbit::Mcp::InternalError' do
        expect { handler.invoke }.to raise_error(API::Orbit::Mcp::InternalError, /Stream ended without result/)
      end
    end
  end
end
