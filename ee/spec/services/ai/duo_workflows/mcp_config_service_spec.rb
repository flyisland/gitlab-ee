# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::McpConfigService, feature_category: :duo_agent_platform do
  let_it_be(:organization) { create(:organization) }
  let_it_be_with_reload(:user) { create(:user, organizations: [organization]) }
  let(:gitlab_token) { 'test_gitlab_token_12345' }
  let(:workflow_definition) { 'chat' }
  let(:ai_catalog_item_version_id) { nil }
  let(:built_in_tool_ids) { [] }
  let(:mcp_tools) { [] }

  let(:mcp_server_tool_names) do
    described_class::GITLAB_PREAPPROVED_TOOLS + %w[
      get_issue create_issue create_workitem_note get_mcp_server_version
    ]
  end

  let(:tool_stub) { double }

  before do
    described_class.instance_variable_set(:@all_mcp_tools, nil)

    manager_instance = instance_double(Mcp::Tools::Manager)
    allow(Mcp::Tools::Manager).to receive(:new).and_return(manager_instance)
    allow(manager_instance).to receive(:list_tools).and_return(
      mcp_server_tool_names.index_with { tool_stub }
    )

    item_version = double('Ai::Catalog::ItemVersion', def_tools: built_in_tool_ids, def_mcp_tools: mcp_tools) # rubocop:disable RSpec/VerifiedDoubles -- def_tools/def_mcp_tools are method_missing accessors on ItemVersion
    allow(service).to receive(:item_version).and_return(item_version)
  end

  subject(:service) do
    described_class.new(
      user,
      gitlab_token,
      workflow_definition: workflow_definition,
      ai_catalog_item_version_id: ai_catalog_item_version_id
    )
  end

  describe '#execute' do
    context 'with default chat (no catalog agent)' do
      it 'returns configuration hash with gitlab server' do
        result = service.execute

        expect(result).to be_a(Hash)
        expect(result).to have_key(:gitlab)
      end

      it 'omits the Tools key to allow all MCP server tools' do
        result = service.execute

        expect(result[:gitlab]).not_to have_key(:Tools)
      end

      it 'includes default preapproved tools' do
        result = service.execute

        expect(result[:gitlab][:PreApprovedTools]).to eq(described_class::GITLAB_PREAPPROVED_TOOLS)
      end

      it 'includes proper authorization header with token' do
        result = service.execute

        expect(result[:gitlab][:Headers][:Authorization]).to eq("Bearer #{gitlab_token}")
      end

      it 'marks the server as trusted' do
        result = service.execute

        expect(result[:gitlab][:Trusted]).to be(true)
      end
    end

    context 'with a catalog agent that has both built-in tool IDs and MCP tools' do
      let(:built_in_tool_ids) { [17, 6] }
      let(:mcp_tools) { %w[search create_workitem_note] }

      it 'includes tools from both sources that exist on the MCP server' do
        result = service.execute

        expect(result[:gitlab][:Tools]).to match_array(
          %w[get_issue create_issue search create_workitem_note]
        )
      end

      it 'preapproves all agent-selected MCP tools' do
        result = service.execute

        expect(result[:gitlab][:PreApprovedTools]).to match_array(
          %w[get_issue create_issue search create_workitem_note]
        )
      end

      it 'does not include tools not selected by the agent' do
        result = service.execute

        expect(result[:gitlab][:Tools]).not_to include('get_mcp_server_version')
      end

      it 'memoizes mcp_tools_for_agent' do
        config = service.execute
        reloaded_config = service.execute

        expect(config[:gitlab][:Tools]).to eq(reloaded_config[:gitlab][:Tools])
        expect(config[:gitlab][:Tools].object_id).to eq(reloaded_config[:gitlab][:Tools].object_id)
      end
    end

    context 'with only mcp_tools enabled' do
      let(:built_in_tool_ids) { nil }
      let(:mcp_tools) { %w[search semantic_code_search] }

      it 'includes only MCP tools that exist on the server' do
        result = service.execute

        expect(result[:gitlab][:Tools]).to match_array(%w[search semantic_code_search])
      end
    end

    context 'with a catalog agent that has tools NOT on the MCP server' do
      let(:built_in_tool_ids) { [10] }
      let(:mcp_tools) { %w[search] }

      it 'includes only tools that exist on the MCP server' do
        result = service.execute

        # edit_file (ID 10) is not in the MCP server tool list, so it's excluded
        expect(result[:gitlab][:Tools]).to match_array(%w[search])
        expect(result[:gitlab][:Tools]).not_to include('edit_file')
      end
    end

    context 'with only built-in tools not on the MCP server' do
      let(:built_in_tool_ids) { [10, 11] }

      it 'returns built-in tools unfiltered' do
        result = service.execute

        expect(result[:gitlab][:Tools]).to match_array(%w[edit_file find_files])
      end
    end

    context 'when mcp_client feature flag is disabled' do
      before do
        stub_feature_flags(mcp_client: false)
      end

      it 'returns nil' do
        expect(service.execute).to be_nil
      end
    end

    context 'when mcp_catalog_agent_tools is disabled for a custom agent' do
      let(:workflow_definition) { 'custom_agent' }
      let(:built_in_tool_ids) { [17, 6] }
      let(:mcp_tools) { %w[search create_workitem_note] }

      before do
        stub_feature_flags(mcp_catalog_agent_tools: false)
      end

      it 'includes built-in tools but excludes MCP tools' do
        result = service.execute

        expect(result[:gitlab][:Tools]).to include('get_issue', 'create_issue')
        expect(result[:gitlab][:Tools]).not_to include('search', 'create_workitem_note')
      end
    end

    context 'when mcp_catalog_agent_tools is enabled for a custom agent with both built-in and MCP tools' do
      let(:workflow_definition) { 'custom_agent' }
      let(:built_in_tool_ids) { [17, 6] }
      let(:mcp_tools) { %w[search create_workitem_note] }

      it 'preserves built-in tools that exist on the MCP server alongside MCP tools' do
        result = service.execute

        expect(result[:gitlab][:Tools]).to match_array(
          %w[get_issue create_issue search create_workitem_note]
        )
      end
    end

    context 'with different gitlab tokens' do
      it 'uses the provided token in authorization header' do
        custom_token = 'custom_token_xyz'
        custom_service = described_class.new(
          user,
          custom_token,
          workflow_definition: 'chat',
          ai_catalog_item_version_id: nil
        )

        result = custom_service.execute

        expect(result[:gitlab][:Headers][:Authorization]).to eq("Bearer #{custom_token}")
      end
    end

    context 'when ai_catalog_item_version_id is provided' do
      let_it_be(:mcp_server) do
        create(
          :ai_catalog_mcp_server,
          organization: organization,
          name: 'Test MCP Server',
          url: 'https://mcp.example.com',
          auth_type: :oauth
        )
      end

      let_it_be(:mcp_servers_user) do
        create(
          :ai_catalog_mcp_servers_user,
          mcp_server: mcp_server,
          user: user,
          organization: organization,
          token: 'user_mcp_token_123'
        )
      end

      let_it_be_with_reload(:item) { create(:ai_catalog_item, :agent, organization: organization, public: true) }
      let_it_be(:item_version) do
        create(
          :ai_catalog_item_version,
          item: item,
          organization: organization,
          definition: {
            system_prompt: 'Test prompt',
            tools: [],
            mcp_servers: [mcp_server.id]
          }
        )
      end

      let(:ai_catalog_item_version_id) { item_version.id }

      before do
        allow(::Ai::Catalog).to receive(:mcp_servers_available?).with(user).and_return(true)
      end

      it 'includes user MCP servers in the configuration' do
        result = service.execute

        expect(result).to have_key(:gitlab)
        expect(result).to have_key(:test_mcp_server)
      end

      it 'includes proper MCP server configuration' do
        result = service.execute

        expect(result[:test_mcp_server]).to match(
          URL: 'https://mcp.example.com',
          Headers: { Authorization: 'Bearer user_mcp_token_123' }
        )
      end

      context 'when MCP server has no_auth type' do
        let_it_be(:no_auth_server) do
          create(
            :ai_catalog_mcp_server,
            organization: organization,
            name: 'No Auth Server',
            url: 'https://noauth.example.com',
            auth_type: :no_auth
          )
        end

        let_it_be(:no_auth_servers_user) do
          create(
            :ai_catalog_mcp_servers_user,
            mcp_server: no_auth_server,
            user: user,
            organization: organization
          )
        end

        let_it_be(:item_version_with_no_auth) do
          create(
            :ai_catalog_item_version,
            item: item,
            organization: organization,
            definition: {
              system_prompt: 'Test prompt',
              tools: [],
              mcp_servers: [no_auth_server.id]
            }
          )
        end

        let(:ai_catalog_item_version_id) { item_version_with_no_auth.id }

        it 'includes MCP server with empty headers' do
          result = service.execute

          expect(result[:no_auth_server]).to match(
            URL: 'https://noauth.example.com',
            Headers: {}
          )
        end
      end

      context 'when user does not have MCP server user association' do
        let_it_be(:server_without_user) do
          create(
            :ai_catalog_mcp_server,
            organization: organization,
            name: 'Server Without User',
            url: 'https://noaccess.example.com',
            auth_type: :oauth
          )
        end

        let_it_be(:item_version_without_user) do
          create(
            :ai_catalog_item_version,
            item: item,
            organization: organization,
            definition: {
              system_prompt: 'Test prompt',
              tools: [],
              mcp_servers: [server_without_user.id]
            }
          )
        end

        let(:ai_catalog_item_version_id) { item_version_without_user.id }

        it 'includes server with empty headers' do
          result = service.execute

          expect(result[:server_without_user]).to match(
            URL: 'https://noaccess.example.com',
            Headers: {}
          )
        end
      end

      context 'when item version does not exist' do
        let(:ai_catalog_item_version_id) { non_existing_record_id }

        it 'does not include catalog MCP servers' do
          result = service.execute

          expect(result).to have_key(:gitlab)
          expect(result).not_to have_key(:test_mcp_server)
        end
      end

      context 'when item version has no mcp_servers in definition' do
        let_it_be(:item_version_no_servers) do
          create(
            :ai_catalog_item_version,
            item: item,
            organization: organization,
            definition: {
              system_prompt: 'Test prompt',
              tools: []
            }
          )
        end

        let(:ai_catalog_item_version_id) { item_version_no_servers.id }

        it 'does not include catalog MCP servers' do
          result = service.execute

          expect(result).to have_key(:gitlab)
          expect(result).not_to have_key(:test_mcp_server)
        end
      end

      context 'when mcp servers are not available' do
        before do
          allow(::Ai::Catalog).to receive(:mcp_servers_available?).with(user).and_return(false)
        end

        it 'does not include catalog MCP servers' do
          result = service.execute

          expect(result).to have_key(:gitlab)
          expect(result).not_to have_key(:test_mcp_server)
        end
      end

      context 'when user is not authorized to read the item version' do
        before do
          item.update!(public: false)
        end

        it 'does not include MCP servers from unauthorized item versions' do
          result = service.execute

          expect(result).to have_key(:gitlab)
          expect(result).not_to have_key(:test_mcp_server)
        end
      end
    end

    context 'when workflow_definition is for agentic chat' do
      let(:workflow_definition) { 'chat' }

      it 'returns MCP server configuration' do
        expect(service.execute).to be_a(Hash)
        expect(service.execute).to have_key(:gitlab)
      end
    end

    context 'when workflow_definition is for a foundational agent without configured tools' do
      where(:workflow_definition) { [nil, '', 'software_development', 'analytics_agent/v1', 'code_review/v2'] }

      with_them do
        it 'returns empty hash' do
          expect(service.execute).to eq({})
        end
      end
    end

    context 'when workflow_definition is for a foundational agent with mcp_tools configured' do
      let(:workflow_definition) { 'software_development' }
      let(:mcp_tools) { %w[search semantic_code_search] }

      it 'injects the GitLab MCP server with the configured tools' do
        result = service.execute

        expect(result).to have_key(:gitlab)
        expect(result[:gitlab][:Tools]).to match_array(%w[search semantic_code_search])
      end

      it 'preapproves all configured tools' do
        result = service.execute

        expect(result[:gitlab][:PreApprovedTools]).to match_array(%w[search semantic_code_search])
      end
    end
  end

  describe '#gitlab_enabled_tools' do
    context 'with default chat (no catalog agent)' do
      it 'returns default tools' do
        expect(service.gitlab_enabled_tools).to eq(%w[gitlab_search search semantic_code_search])
      end
    end

    context 'with a catalog agent that has tools matching MCP server' do
      let(:built_in_tool_ids) { [17, 6] }
      let(:mcp_tools) { %w[search create_workitem_note] }

      it 'includes tools from both sources' do
        expect(service.gitlab_enabled_tools).to match_array(
          %w[get_issue create_issue search create_workitem_note]
        )
      end
    end

    context 'with a catalog agent using a non-chat workflow definition' do
      let(:workflow_definition) { 'software_development' }
      let(:mcp_tools) { %w[search create_issue] }

      it 'returns the configured tools regardless of workflow definition' do
        expect(service.gitlab_enabled_tools).to match_array(%w[search create_issue])
      end
    end

    context 'when mcp_client feature flag is disabled' do
      before do
        stub_feature_flags(mcp_client: false)
      end

      it 'returns empty array' do
        expect(service.gitlab_enabled_tools).to eq([])
      end
    end

    context 'when workflow_definition is for a foundational agent without configured tools' do
      where(:workflow_definition) { [nil, '', 'software_development', 'analytics_agent/v1', 'code_review/v2'] }

      with_them do
        it 'returns empty array' do
          expect(service.gitlab_enabled_tools).to eq([])
        end
      end
    end
  end

  describe '.all_mcp_tools' do
    it 'returns tool names from Mcp::Tools::Manager' do
      tool_names = described_class.all_mcp_tools

      expect(tool_names).to be_an(Array)
      expect(tool_names).to match_array(mcp_server_tool_names)
    end

    it 'queries the MCP Tools Manager for dynamic tool discovery' do
      described_class.all_mcp_tools

      expect(Mcp::Tools::Manager).to have_received(:new)
    end

    it 'memoizes the result' do
      described_class.all_mcp_tools
      described_class.all_mcp_tools

      expect(Mcp::Tools::Manager).to have_received(:new).once
    end
  end

  describe 'orbit MCP server' do
    before do
      stub_feature_flags(knowledge_graph: user)
    end

    context 'with agentic chat workflow' do
      let(:workflow_definition) { 'chat' }

      it 'includes orbit server with tools and trusted flag' do
        result = service.execute

        expect(result).to have_key(:orbit)
        expect(result[:orbit]).not_to have_key(:Tools)
        expect(result[:orbit][:PreApprovedTools]).to eq(::API::Orbit::McpHandlers::CallTool::KNOWN_TOOLS)
        expect(result[:orbit][:Trusted]).to be(true)
        expect(result[:orbit][:Headers][:Authorization]).to eq("Bearer #{gitlab_token}")
      end
    end

    context 'with a non-chat foundational agent' do
      let(:workflow_definition) { 'security_analyst_agent/v1' }

      it 'does not include orbit server' do
        result = service.execute

        expect(result).not_to have_key(:orbit)
      end
    end

    context 'when knowledge_graph feature flag is disabled' do
      before do
        stub_feature_flags(knowledge_graph: false)
      end

      it 'does not include orbit server' do
        result = service.execute

        expect(result).not_to have_key(:orbit)
      end
    end
  end

  describe 'constants' do
    it 'defines GITLAB_PREAPPROVED_TOOLS' do
      expect(described_class::GITLAB_PREAPPROVED_TOOLS).to eq(%w[gitlab_search search semantic_code_search])
    end

    it 'defines GITLAB_TOOLS_REQUIRING_APPROVAL' do
      expect(described_class::GITLAB_TOOLS_REQUIRING_APPROVAL).to eq([])
    end

    it 'defines GITLAB_ENABLED_TOOLS as the union of preapproved and requiring approval' do
      expect(described_class::GITLAB_ENABLED_TOOLS).to eq(%w[gitlab_search search semantic_code_search])
    end
  end
end
