# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Orbit::McpHandlers::ListTools, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:access_token) { create(:oauth_access_token, user: user, scopes: [:mcp_orbit]) }

  let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }
  let(:request_context) do
    Analytics::KnowledgeGraph::RequestContext.new(source_type: Analytics::KnowledgeGraph::SourceType::MCP)
  end

  subject(:handler) do
    described_class.new(
      {},
      access_token,
      user,
      grpc_client: grpc_client,
      request_context: request_context
    )
  end

  describe '#invoke' do
    context 'when gRPC returns tools' do
      let(:grpc_tools) do
        [
          {
            name: 'query_graph',
            description: 'Query the knowledge graph',
            parameters: { 'type' => 'object', 'properties' => { 'query' => { 'type' => 'string' } } }
          },
          {
            name: 'get_graph_schema',
            description: 'Get the graph schema',
            parameters: { 'type' => 'object', 'properties' => { 'expand_nodes' => { 'type' => 'array' } } }
          },
          {
            name: 'list_commands',
            description: 'List Orbit commands',
            parameters: {
              'type' => 'object',
              'properties' => {
                'command_names' => { 'type' => 'array' },
                'format' => { 'type' => 'string', 'enum' => %w[llm raw] }
              }
            }
          },
          {
            name: 'invoke_command',
            description: 'Invoke an Orbit command',
            parameters: { 'type' => 'object', 'properties' => { 'command_name' => { 'type' => 'string' } } }
          },
          {
            name: 'internal_tool',
            description: 'Internal GKG tool',
            parameters: { 'type' => 'object' }
          }
        ]
      end

      before do
        allow(grpc_client).to receive(:list_tools)
          .with(user: user, request_context: request_context)
          .and_return(grpc_tools)
      end

      context 'when command tools are disabled' do
        before do
          stub_feature_flags(orbit_mcp_command_tools: false)
        end

        it 'returns legacy direct tools in MCP format' do
          result = handler.invoke

          expect(result[:tools]).to be_an(Array)
          expect(result[:tools].pluck(:name)).to eq(%w[query_graph get_graph_schema])
        end
      end

      context 'when command tools are enabled' do
        before do
          stub_feature_flags(orbit_mcp_command_tools: user)
        end

        it 'returns command wrapper tools in MCP format' do
          result = handler.invoke

          expect(result[:tools].pluck(:name)).to eq(%w[list_commands invoke_command])
        end

        it 'marks command tools as trusted' do
          result = handler.invoke

          expect(result[:tools].pluck(:trusted)).to all(be(true))
        end

        it 'exposes format on list_commands input schema' do
          result = handler.invoke

          list_commands = result[:tools].find { |tool| tool[:name] == 'list_commands' }
          expect(list_commands[:inputSchema]['properties']['format']).to eq({
            'type' => 'string',
            'enum' => %w[llm raw]
          })
        end
      end

      it 'maps parameters from gRPC to inputSchema in MCP' do
        stub_feature_flags(orbit_mcp_command_tools: false)

        result = handler.invoke

        result[:tools].each do |tool|
          expect(tool).to have_key(:inputSchema)
          expect(tool).not_to have_key(:parameters)
        end
      end

      it 'maps each tool with name, description, and inputSchema' do
        stub_feature_flags(orbit_mcp_command_tools: false)

        result = handler.invoke

        tool = result[:tools].first
        expect(tool[:name]).to eq('query_graph')
        expect(tool[:description]).to eq('Query the knowledge graph')
        expect(tool[:inputSchema]).to eq({
          'type' => 'object',
          'properties' => { 'query' => { 'type' => 'string' } }
        })
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
          .with(user: user, request_context: request_context)
          .and_return([])
      end

      it 'returns empty tools array' do
        result = handler.invoke

        expect(result[:tools]).to eq([])
      end
    end
  end
end
