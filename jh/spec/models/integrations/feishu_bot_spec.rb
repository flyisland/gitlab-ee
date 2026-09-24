# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::FeishuBot do
  let(:instance_feishu_bot_integration) { create(:feishu_bot_integration, :instance) }

  before do
    stub_licensed_features(feishu_bot_integration: true)
  end

  describe '#create' do
    context 'as instance level' do
      it 'only valid in instance level' do
        aggregate_failures do
          expect(instance_feishu_bot_integration.instance_level?).to be(true)
          expect(instance_feishu_bot_integration.project_level?).to be(false)
          expect(instance_feishu_bot_integration.group_level?).to be(false)
        end
      end

      it 'cannot create when no starter plan' do
        stub_licensed_features(feishu_bot_integration: false)

        integration = build(:feishu_bot_integration, :instance)

        expect(integration.valid?).to be(false)
      end
    end

    context 'as none instance level' do
      it 'cannot update for project level' do
        project = create(:project)
        integration = create(:feishu_bot_integration, project: project)

        expect(integration.valid?(:manual_change)).to be(false)
      end

      it 'cannot update for group level' do
        integration = create(:feishu_bot_integration, :group)

        expect(integration.valid?(:manual_change)).to be(false)
      end
    end
  end

  context 'when validate method value' do
    subject { build(:feishu_bot_integration, :instance) }

    describe '#title' do
      it 'not empty' do
        expect(subject.title).not_to be_empty
      end
    end

    describe '#description' do
      it 'not empty' do
        expect(subject.description).not_to be_empty
      end
    end

    describe '#help' do
      it 'not empty' do
        expect(subject.help).not_to be_empty
      end
    end

    describe '#testable?' do
      it 'be false' do
        expect(subject.testable?).to be(false)
      end
    end

    describe '.to_param' do
      it 'not empty' do
        expect(subject.class.to_param).not_to be_empty
      end
    end

    describe '.supported_events' do
      it 'be empty' do
        expect(subject.class.supported_events).to be_empty
      end
    end

    describe "#chat_responder" do
      it "be specify class" do
        expect(subject.chat_responder).to be(::Gitlab::Chat::Responder::Feishu)
      end
    end
  end
end
