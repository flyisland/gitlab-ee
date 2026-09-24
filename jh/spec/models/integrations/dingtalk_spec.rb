# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Dingtalk, feature_category: :api do
  let(:instance_dingtalk_integration) { create(:dingtalk_integration, :instance) }

  before do
    stub_licensed_features(dingtalk_integration: true)
  end

  describe '#create' do
    context 'as instance level' do
      it 'stores data in data_fields correctly' do
        tracker_data = instance_dingtalk_integration.dingtalk_tracker_data

        expect(tracker_data.corpid).not_to be_nil
        expect(instance_dingtalk_integration.instance_level?).to be(true)
        expect(instance_dingtalk_integration.project_level?).to be(false)
        expect(instance_dingtalk_integration.group_level?).to be(false)
      end

      it 'cannot create when no premium plan' do
        stub_licensed_features(dingtalk_integration: false)

        integration = build(:dingtalk_integration, :instance)

        expect(integration.valid?).to be(false)
      end
    end

    context 'as none instance level' do
      it 'cannot update for project level' do
        project = create(:project)
        integration = create(:dingtalk_integration, project: project)

        expect(integration.valid?(:manual_change)).to be(false)
      end

      it 'cannot update for group level' do
        integration = create(:dingtalk_integration, :group)

        expect(integration.valid?(:manual_change)).to be(false)
      end
    end
  end

  describe '#fields' do
    it 'returns custom fields' do
      expect(create(:dingtalk_integration, :instance).fields.pluck(:name)).to eq(%w[corpid])
    end
  end

  describe '#help' do
    it 'renders prompt information' do
      expect(create(:dingtalk_integration, :instance).help).not_to be_empty
    end
  end
end
