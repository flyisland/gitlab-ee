# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mcp::Tools::Manager, feature_category: :ai_agents do
  let(:mock_tool_handler) { Class.new { def initialize(...); end } }

  before do
    custom_tools = {
      'get_mcp_server_version' => mock_tool_handler
    }
    ee_custom_tools = {
      'get_ee_mcp_server_version' => mock_tool_handler
    }
    stub_const("#{described_class}::CUSTOM_TOOLS", custom_tools)
    stub_const("::EE::#{described_class}::EE_CUSTOM_TOOLS", ee_custom_tools)

    # Stub the GRAPHQL_TOOLS with GraphQL tools
    graphql_tools = {
      'add_commit' => mock_tool_handler,
      'create_workitem_note' => mock_tool_handler
    }
    ee_graphql_tools = {
      'ee_create_workitem_note' => mock_tool_handler
    }
    stub_const("#{described_class}::GRAPHQL_TOOLS", graphql_tools)
    stub_const("::EE::#{described_class}::EE_GRAPHQL_TOOLS", ee_graphql_tools)
  end

  describe '#get_tool' do
    let(:manager) { described_class.new }

    describe 'semantic search tool' do
      it 'surfaces semantic_search not semantic_code_search as a standalone tool' do
        expect(manager.list_tools.keys).to include('semantic_search')
        expect(manager.list_tools.keys).not_to include('semantic_code_search')
      end

      it 'resolves semantic_code_search alias to semantic_search' do
        expect(manager.resolve_alias('semantic_code_search')).to eq('semantic_search')

        tool = manager.get_tool(name: 'semantic_code_search')
        expect(tool).to be_a(Mcp::Tools::SemanticSearch::SemanticSearchService)
      end
    end
  end

  describe '#initialize' do
    let(:routes) { [] }
    let(:fake_api_class) { Class.new(API::Base) }

    before do
      allow(API::Base).to receive(:descendants).and_return([fake_api_class])
      allow(fake_api_class).to receive(:routes).and_return(routes)
    end

    context 'with no API routes' do
      it 'initializes with custom and graphql tools' do
        manager = described_class.new

        expect(manager.tools.keys).to contain_exactly(
          'get_mcp_server_version',
          'get_ee_mcp_server_version',
          'create_workitem_note',
          'ee_create_workitem_note',
          'add_commit'
        )
      end
    end
  end
end
