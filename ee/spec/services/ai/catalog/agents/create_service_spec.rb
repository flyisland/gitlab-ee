# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::Agents::CreateService, feature_category: :workflow_catalog do
  include Ai::Catalog::TestHelpers

  let_it_be(:maintainer) { create(:user) }
  let_it_be(:project) { create(:project, maintainers: maintainer) }

  let(:user) { maintainer }
  let(:params) do
    {
      name: 'Agent',
      description: 'Description',
      public: true,
      tools: [Ai::Catalog::BuiltInTool.find(1)],
      system_prompt: 'A',
      user_prompt: 'B'
    }
  end

  before do
    enable_ai_catalog
  end

  subject(:service) { described_class.new(project: project, current_user: user, params: params) }

  it_behaves_like Ai::Catalog::Items::BaseCreateService do
    let(:expected_item_type) { Ai::Catalog::Item::AGENT_TYPE }
    let(:expected_item_schema_version) { Ai::Catalog::ItemVersion::AGENT_SCHEMA_VERSION }
    let(:expected_audit_event_create_item_message) do
      'Created a new public AI agent with tools: [gitlab_blob_search]'
    end

    let(:expected_audit_event_item_name) { 'AI agent' }
    let(:expected_updated_definition) do
      {
        mcp_servers: [],
        mcp_tools: [],
        system_prompt: params[:system_prompt],
        tools: [1],
        user_prompt: params[:user_prompt]
      }
    end
  end

  context 'when mcp_tools are provided' do
    let(:params) { super().merge(mcp_tools: %w[search create_issue]) }

    it 'creates a catalog item with mcp_tools in definition' do
      expect { service.execute }.to change { Ai::Catalog::Item.count }.by(1)

      item = Ai::Catalog::Item.last
      expect(item.latest_version.definition['mcp_tools']).to match_array(%w[search create_issue])
    end
  end

  context 'when mcp_servers are provided' do
    let_it_be(:mcp_server1) { create(:ai_catalog_mcp_server) }
    let_it_be(:mcp_server2) { create(:ai_catalog_mcp_server) }
    let(:params) { super().merge(mcp_servers: [mcp_server1.id, mcp_server2.id]) }

    it 'creates a catalog item with mcp_servers in definition' do
      expect { service.execute }.to change { Ai::Catalog::Item.count }.by(1)

      item = Ai::Catalog::Item.last
      expect(item.latest_version.definition['mcp_servers']).to match_array([mcp_server1.id, mcp_server2.id])
    end
  end
end
