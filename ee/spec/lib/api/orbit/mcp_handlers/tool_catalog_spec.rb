# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Orbit::McpHandlers::ToolCatalog, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }

  describe 'ALL_LEGACY_TOOL_NAMES' do
    it 'includes get_graph_status in addition to the discoverable legacy tools' do
      expect(described_class::ALL_LEGACY_TOOL_NAMES)
        .to match_array(%w[query_graph get_graph_schema get_graph_status])
    end
  end

  describe '.visible_tool_names' do
    context 'when orbit_mcp_command_tools is enabled' do
      before do
        stub_feature_flags(orbit_mcp_command_tools: user)
      end

      it 'returns the command tools' do
        expect(described_class.visible_tool_names(user)).to eq(described_class::COMMAND_TOOL_NAMES)
      end
    end

    context 'when orbit_mcp_command_tools is disabled' do
      before do
        stub_feature_flags(orbit_mcp_command_tools: false)
      end

      it 'returns the legacy tools' do
        expect(described_class.visible_tool_names(user)).to eq(described_class::LEGACY_TOOL_NAMES)
      end
    end
  end

  describe '.legacy_tools_enabled?' do
    context 'when orbit_use_legacy_tools is enabled (default)' do
      it 'returns true' do
        expect(described_class.legacy_tools_enabled?(user)).to be(true)
      end
    end

    context 'when orbit_use_legacy_tools is disabled' do
      before do
        stub_feature_flags(orbit_use_legacy_tools: false)
      end

      it 'returns false' do
        expect(described_class.legacy_tools_enabled?(user)).to be(false)
      end
    end

    context 'when orbit_use_legacy_tools is enabled only for a specific user' do
      let_it_be(:other_user) { create(:user) }

      before do
        stub_feature_flags(orbit_use_legacy_tools: user)
      end

      it 'returns true for the enabled user' do
        expect(described_class.legacy_tools_enabled?(user)).to be(true)
      end

      it 'returns false for other users' do
        expect(described_class.legacy_tools_enabled?(other_user)).to be(false)
      end
    end
  end

  describe '.trusted_tool?' do
    it 'returns true for trusted tool names' do
      expect(described_class.trusted_tool?('query_graph')).to be(true)
      expect(described_class.trusted_tool?('invoke_command')).to be(true)
    end

    it 'returns false for unknown tool names' do
      expect(described_class.trusted_tool?('nonexistent')).to be(false)
    end
  end
end
