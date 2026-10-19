# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::Workflow, feature_category: :duo_agent_platform do
  describe 'source_type enum' do
    it 'includes the JH values without clobbering upstream values' do
      expect(described_class.source_types).to include('slack' => 1, 'mcp' => 2, 'dingtalk' => 100, 'feishu' => 101)
    end

    it 'keeps source types upstream adds after the JH value was introduced' do
      klass = Class.new(ApplicationRecord) do
        self.table_name = 'duo_workflows_workflows'

        enum :source_type, { slack: 1, mcp: 2, ide_extension: 13 }, prefix: :source
      end

      klass.prepend(JH::Ai::DuoWorkflows::Workflow)

      expect(klass.source_types).to eq(
        'slack' => 1, 'mcp' => 2, 'ide_extension' => 13, 'dingtalk' => 100, 'feishu' => 101
      )
    end

    it 'persists the dingtalk value' do
      workflow = create(:duo_workflows_workflow, source_type: :dingtalk)

      expect(workflow.reload.source_type).to eq('dingtalk')
      expect(workflow.source_dingtalk?).to be(true)
    end

    it 'persists the feishu value', :aggregate_failures do
      workflow = create(:duo_workflows_workflow, source_type: :feishu)

      expect(workflow.reload.source_type).to eq('feishu')
      expect(workflow.source_feishu?).to be(true)
      expect(workflow.source_dingtalk?).to be(false)
      expect(described_class.source_feishu).to contain_exactly(workflow)
      expect(described_class.not_source_feishu).not_to include(workflow)
    end
  end
end
