# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::McpTool, feature_category: :workflow_catalog do
  describe 'included modules' do
    subject { described_class }

    it { is_expected.to include(ActiveRecord::FixedItemsModel::Model) }
    it { is_expected.to include(GlobalID::Identification) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '.fixed_items' do
    it 'returns tools from Mcp::Tools::Manager' do
      items = described_class.fixed_items

      expect(items).to be_an(Array)
      expect(items).to all(include(:name, :title, :description))
    end

    it 'humanizes tool names for the title' do
      items = described_class.fixed_items

      items.each do |item|
        expect(item[:title]).not_to include('_')
      end
    end

    context 'when SafeRequestStore is active', :request_store do
      it 'memoizes the result within a request' do
        first_call = described_class.fixed_items
        second_call = described_class.fixed_items

        expect(first_call).to equal(second_call)
      end
    end

    context 'when a tool raises on description extraction' do
      let(:broken_tool) do
        Class.new do
          def description
            raise StandardError, 'unexpected extraction error'
          end
        end.new
      end

      let(:llm_logger) { instance_double(Gitlab::Llm::Logger) }

      before do
        manager = instance_double(Mcp::Tools::Manager)
        allow(Mcp::Tools::Manager).to receive(:new).and_return(manager)
        allow(manager).to receive(:list_tools).and_return({ 'broken_tool' => broken_tool })
        allow(Gitlab::Llm::Logger).to receive(:build).and_return(llm_logger)
      end

      it 'logs the error and falls back to DEFAULT_DESCRIPTION' do
        expect(llm_logger).to receive(:error).with(
          hash_including(
            message: 'Failed to extract MCP tool description',
            event_name: 'mcp_tool_description_extraction_error',
            ai_component: 'workflow_catalog',
            error: 'unexpected extraction error'
          )
        )

        items = described_class.fixed_items

        expect(items.first[:description]).to eq(described_class::DEFAULT_DESCRIPTION)
      end
    end
  end

  describe '.find_by_name' do
    it 'returns the tool matching the given name' do
      tool = described_class.all.first
      found = described_class.find_by_name(tool.name)

      expect(found).to be_present
      expect(found.name).to eq(tool.name)
    end

    it 'returns nil when no tool matches' do
      expect(described_class.find_by_name('nonexistent_tool')).to be_nil
    end
  end

  describe '.all' do
    it 'returns discovered MCP tools' do
      expect(described_class.all.size).to be_positive
    end
  end

  describe 'tool attributes' do
    it 'each tool has a name, title, and description' do
      described_class.all.each do |tool| # rubocop:disable Rails/FindEach -- FixedItemsModel does not support find_each
        expect(tool.name).to be_present
        expect(tool.title).to be_present
        expect(tool.description).to be_present
      end
    end
  end
end
