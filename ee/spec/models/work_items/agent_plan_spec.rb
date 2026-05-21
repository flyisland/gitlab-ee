# frozen_string_literal: true

require "spec_helper"

RSpec.describe WorkItems::AgentPlan, feature_category: :team_planning do
  describe 'associations' do
    it { is_expected.to belong_to(:work_item) }
    it { is_expected.to belong_to(:namespace) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:namespace) }
    it { is_expected.to validate_presence_of(:work_item) }

    it 'sets namespace from work_item before validation' do
      work_item = create(:work_item)
      agent_plan = described_class.new(work_item: work_item)

      expect(agent_plan).to be_valid
      expect(agent_plan.namespace).to eq(work_item.namespace)
    end

    it 'does not raise when work_item is nil' do
      agent_plan = described_class.new(work_item: nil)
      agent_plan.valid?
      expect(agent_plan.namespace).to be_nil
    end

    it { is_expected.to validate_length_of(:content).is_at_most(described_class::CONTENT_LENGTH_MAX) }
  end

  describe 'external markdown storage' do
    let(:work_item) { create(:work_item) }

    it 'persists content to object storage and reads it back' do
      agent_plan = create(:work_item_agent_plan, work_item: work_item, content: '**bold text**')

      reloaded = described_class.find(agent_plan.work_item_id)
      expect(reloaded.content).to eq('**bold text**')
    end

    it 'caches rendered content_html in object storage' do
      agent_plan = create(:work_item_agent_plan, work_item: work_item, content: '**bold**')

      reloaded = described_class.find(agent_plan.work_item_id)
      expect(reloaded.content_html).to include('<strong')
      expect(reloaded.content_html).to include('bold</strong>')
    end

    it 'does not load content from storage until accessed' do
      agent_plan = create(:work_item_agent_plan, work_item: work_item, content: 'lazy test')

      reloaded = described_class.find(agent_plan.work_item_id)
      expect(reloaded.instance_variable_get(:@external_fields_loaded)).to be_nil

      expect(reloaded.cached_markdown_version).to be_present
      expect(reloaded.instance_variable_get(:@external_fields_loaded)).to be_nil

      reloaded.content
      expect(reloaded.instance_variable_get(:@external_fields_loaded)).to be true
    end

    it 'updates content in object storage on save' do
      agent_plan = create(:work_item_agent_plan, work_item: work_item, content: 'original')

      agent_plan.content = 'updated'
      agent_plan.save!

      reloaded = described_class.find(agent_plan.work_item_id)
      expect(reloaded.content).to eq('updated')
      expect(reloaded.content_html).to be_present
    end

    it 'cleans up object storage on destroy' do
      agent_plan = create(:work_item_agent_plan, work_item: work_item, content: 'to be deleted')

      uploader = agent_plan.send(:external_storage_uploader)
      stored_path = uploader.path
      expect(File.exist?(stored_path)).to be true

      agent_plan.destroy!

      expect(File.exist?(stored_path)).to be false
    end
  end
end
