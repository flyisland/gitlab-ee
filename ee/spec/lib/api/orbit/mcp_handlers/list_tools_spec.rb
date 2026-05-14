# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Orbit::McpHandlers::ListTools, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:access_token) { create(:oauth_access_token, user: user, scopes: [:mcp_orbit]) }

  let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }

  subject(:handler) do
    described_class.new(
      {},
      access_token,
      user,
      source_type: Analytics::KnowledgeGraph::SourceType::MCP,
      grpc_client: grpc_client
    )
  end

  describe '#invoke' do
    context 'when gRPC returns tools' do
      let(:grpc_tools) do
        [
          {
            name: 'search_graph',
            description: 'Search the knowledge graph',
            parameters: { 'type' => 'object', 'properties' => { 'query' => { 'type' => 'string' } } }
          },
          {
            name: 'get_node',
            description: 'Get a node by ID',
            parameters: { 'type' => 'object', 'properties' => { 'id' => { 'type' => 'integer' } } }
          }
        ]
      end

      before do
        allow(grpc_client).to receive(:list_tools)
          .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return(grpc_tools)
      end

      it 'returns tools in MCP format' do
        result = handler.invoke

        expect(result[:tools]).to be_an(Array)
        expect(result[:tools].length).to eq(2)
      end

      it 'maps each tool with name, description, and inputSchema' do
        result = handler.invoke

        tool = result[:tools].first
        expect(tool[:name]).to eq('search_graph')
        expect(tool[:description]).to eq('Search the knowledge graph')
        expect(tool[:inputSchema]).to eq({
          'type' => 'object',
          'properties' => { 'query' => { 'type' => 'string' } }
        })
      end

      it 'maps parameters from gRPC to inputSchema in MCP' do
        result = handler.invoke

        result[:tools].each do |tool|
          expect(tool).to have_key(:inputSchema)
          expect(tool).not_to have_key(:parameters)
        end
      end
    end

    context 'when gRPC raises ConnectionError' do
      before do
        allow(grpc_client).to receive(:list_tools)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::ConnectionError, 'list_tools failed: connection refused')
      end

      it 'returns empty tools array' do
        result = handler.invoke

        expect(result[:tools]).to eq([])
      end
    end

    context 'when gRPC returns empty tools list' do
      before do
        allow(grpc_client).to receive(:list_tools)
          .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::MCP)
          .and_return([])
      end

      it 'returns empty tools array' do
        result = handler.invoke

        expect(result[:tools]).to eq([])
      end
    end
  end
end
