# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ToolRule, feature_category: :duo_agent_platform do
  let_it_be(:namespace) { create(:namespace) }

  describe 'associations' do
    it { is_expected.to belong_to(:namespace) }
  end

  describe 'validations' do
    subject(:tool_rule) { build(:ai_tool_rule, namespace: namespace) }

    it { is_expected.to validate_presence_of(:namespace) }
    it { is_expected.to validate_presence_of(:tool_name) }
    it { is_expected.to validate_uniqueness_of(:tool_name).scoped_to(:namespace_id) }

    describe 'tool_name inclusion' do
      it 'is valid with a known tool name' do
        tool_rule.tool_name = 'create_issue'

        expect(tool_rule).to be_valid
      end

      it 'is invalid with an unknown tool name' do
        tool_rule.tool_name = 'invented_tool'

        expect(tool_rule).not_to be_valid
        expect(tool_rule.errors[:tool_name]).to include(/is not a known tool name/)
      end
    end

    describe 'validate_access_permissions_present' do
      it 'is valid when only web_access is set' do
        tool_rule.web_access = :ask
        tool_rule.local_access = nil

        expect(tool_rule).to be_valid
      end

      it 'is valid when only local_access is set' do
        tool_rule.web_access = nil
        tool_rule.local_access = :deny

        expect(tool_rule).to be_valid
      end

      it 'is valid when both are set' do
        tool_rule.web_access = :allow
        tool_rule.local_access = :ask

        expect(tool_rule).to be_valid
      end

      it 'is invalid when both are nil' do
        tool_rule.web_access = nil
        tool_rule.local_access = nil

        expect(tool_rule).not_to be_valid
        expect(tool_rule.errors[:base]).to include(/must have at least one/)
      end
    end

    describe 'enum values' do
      it 'accepts allow, ask, deny for web_access' do
        %i[allow ask deny].each do |value|
          tool_rule.web_access = value

          expect(tool_rule).to be_valid
        end
      end

      it 'accepts allow, ask, deny for local_access' do
        %i[allow ask deny].each do |value|
          tool_rule.local_access = value

          expect(tool_rule).to be_valid
        end
      end

      it 'raises on invalid enum value' do
        expect { tool_rule.web_access = :invalid }.to raise_error(ArgumentError)
      end
    end

    describe 'tool_arguments json schema' do
      it 'is valid when tool_arguments is nil' do
        tool_rule.tool_arguments = nil

        expect(tool_rule).to be_valid
      end

      it 'is valid with properly formatted tool_arguments' do
        tool_rule.tool_arguments = { 'param1' => 'value1', 'param2' => 42 }

        expect(tool_rule).to be_valid
      end

      it 'is invalid when tool_arguments is not an object' do
        tool_rule.tool_arguments = [1, 2, 3]

        expect(tool_rule).not_to be_valid
        expect(tool_rule.errors[:tool_arguments]).to be_present
      end

      it 'is invalid when tool_arguments exceeds size limit' do
        tool_rule.tool_arguments = { 'key' => 'a' * 64.kilobytes }

        expect(tool_rule).not_to be_valid
        expect(tool_rule.errors[:tool_arguments]).to be_present
      end
    end
  end

  describe 'scopes' do
    describe '.for_namespace' do
      let_it_be(:other_namespace) { create(:namespace) }
      let_it_be(:rule) { create(:ai_tool_rule, namespace: namespace) }
      let_it_be(:other_rule) { create(:ai_tool_rule, namespace: other_namespace, tool_name: 'read_file') }

      it 'returns rules for the given namespace' do
        expect(described_class.for_namespace(namespace.id)).to contain_exactly(rule)
      end

      it 'does not return rules for other namespaces' do
        expect(described_class.for_namespace(namespace.id)).not_to include(other_rule)
      end

      it 'returns empty when no rules exist for namespace' do
        expect(described_class.for_namespace(create(:namespace).id)).to be_empty
      end
    end
  end
end
