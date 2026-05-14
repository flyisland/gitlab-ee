# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::FoundationalFlow, feature_category: :duo_agent_platform do
  include I18nHelper

  let(:fr_translations) do
    {
      'FoundationalFlow|Code Review' => 'Code Review in French',
      'FoundationalFlow|Streamline code reviews by analyzing code changes, comments, and linked issues.' =>
        'Code Review description in French'
    }
  end

  describe '.fixed_items' do
    it 'does not translate display_name' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(described_class['code_review/v1'].display_name)
          .to eq('Code Review')
      end
    end

    it 'does not translate description' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(described_class['code_review/v1'].description)
          .to eq('Streamline code reviews by analyzing code changes, comments, and linked issues.')
      end
    end
  end

  describe '.[]' do
    subject(:definition) { described_class[key] }

    context 'with a valid foundational_flow_reference' do
      let(:key) { 'code_review/v1' }

      it { is_expected.to eq(described_class.find_by(foundational_flow_reference: key)) }
    end

    context 'with a valid display_name (for backward compatibility)' do
      let(:key) { 'Code Review' }

      it { is_expected.to eq(described_class.find_by(display_name: key)) }
    end

    context 'with a invalid key' do
      let(:key) { 'foo' }

      it { is_expected.to be_nil }
    end
  end

  describe '.beta?' do
    subject(:beta?) { described_class.beta?(foundational_flow_reference) }

    context 'when foundational flow is beta' do
      before do
        allow(described_class).to receive(:find_by)
          .with(foundational_flow_reference: 'some_beta_flow/v1')
          .and_return(instance_double(described_class, feature_maturity: 'beta'))
      end

      let(:foundational_flow_reference) { 'some_beta_flow/v1' }

      it { is_expected.to be true }
    end

    context 'when foundational flow is GA' do
      let(:foundational_flow_reference) { 'code_review/v1' }

      it { is_expected.to be false }
    end

    context 'when foundational flow does not exist' do
      let(:foundational_flow_reference) { 'non_existent/v1' }

      it { is_expected.to be false }
    end
  end

  describe '.ultimate_only?' do
    subject(:ultimate_only?) { described_class.ultimate_only?(foundational_flow_reference) }

    context 'when foundational flow is ultimate-only' do
      let(:foundational_flow_reference) { 'resolve_sast_vulnerability/v1' }

      it { is_expected.to be true }
    end

    context 'when foundational flow is not ultimate-only' do
      let(:foundational_flow_reference) { 'code_review/v1' }

      it { is_expected.to be false }
    end

    context 'when foundational flow does not exist' do
      let(:foundational_flow_reference) { 'non_existent/v1' }

      it { is_expected.to be false }
    end
  end

  describe '.ga' do
    subject(:ga) { described_class.ga }

    it 'returns flows where feature_maturity is ga only' do
      expect(ga.map(&:feature_maturity).uniq).to eq(['ga'])
    end
  end

  describe 'fix_pipeline/v1' do
    subject(:flow) { described_class['fix_pipeline/v1'] }

    it 'has supported_events limited to pipeline_hooks' do
      expect(flow.supported_events).to eq([::Ai::FlowTrigger::EVENT_TYPES[:pipeline_hooks]])
    end

    it 'has a precondition requiring failed pipeline status' do
      expect(flow.precondition).to eq({
        'match' => 'all',
        'rules' => [
          { 'field' => 'object_attributes.status', 'operator' => 'eq', 'value' => 'failed' }
        ]
      })
    end
  end

  describe '#agent_privileges' do
    subject(:agent_privileges) { definition.agent_privileges }

    context 'with empty agent_privileges' do
      let(:definition) { described_class.new(agent_privileges: [], pre_approved_agent_privileges: [1, 2]) }

      it 'copies pre_approved_agent_privileges' do
        expect(agent_privileges).to match_array([1, 2])
      end
    end

    context 'when agent_privileges are not set' do
      let(:definition) { described_class.new(agent_privileges: nil) }

      it 'returns the default value' do
        expect(agent_privileges).to eq([])
      end
    end

    context 'with agent_privileges' do
      let(:definition) { described_class.new(agent_privileges: [1, 2]) }

      it 'returns the agent_privileges' do
        expect(agent_privileges).to match_array([1, 2])
      end
    end
  end

  describe '#catalog_item' do
    subject(:catalog_item) { definition.catalog_item }

    context 'with foundational_flow_reference' do
      let_it_be(:definition) { described_class.new(foundational_flow_reference: 'code_review') }
      let_it_be(:duo_code_review) { create(:ai_catalog_item, foundational_flow_reference: 'code_review') }

      it 'returns the corresponding foundational workflow catalog item' do
        expect(catalog_item).to eq(duo_code_review)
      end
    end

    context 'without foundational_flow_reference' do
      let_it_be(:definition) { described_class.new(foundational_flow_reference: nil) }

      it 'returns nil' do
        expect(catalog_item).to be_nil
      end
    end

    context 'when the corresponding foundational workflow does not exist' do
      let_it_be(:definition) { described_class.new(foundational_flow_reference: 'code_review') }

      it 'returns nil' do
        expect(catalog_item).to be_nil
      end
    end
  end

  describe '#display_name' do
    subject(:display_name) { definition.display_name }

    let(:definition) { described_class['code_review/v1'] }

    it 'does not translate if locale is not English' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(display_name).to eq('Code Review')
      end
    end
  end

  describe '#description' do
    subject(:description) { definition.description }

    let(:definition) { described_class['code_review/v1'] }

    it 'does not translate if locale is not English' do
      with_stubbed_translations(:fr, fr_translations) do
        expect(description).to eq('Streamline code reviews by analyzing code changes, comments, and linked issues.')
      end
    end
  end

  describe '#translated_display_name' do
    subject(:translated_display_name) { definition.translated_display_name }

    let(:definition) { described_class['code_review/v1'] }

    context 'when the locale is English' do
      it 'returns the English display_name' do
        Gitlab::I18n.with_locale(:en) do
          expect(translated_display_name).to eq('Code Review')
        end
      end
    end

    context 'when the locale is not English' do
      it 'returns the translated display_name' do
        with_stubbed_translations(:fr, fr_translations) do
          expect(translated_display_name).to eq('Code Review in French')
        end
      end
    end
  end

  describe '#translated_description' do
    subject(:translated_description) { definition.translated_description }

    let(:definition) { described_class['code_review/v1'] }

    context 'when the locale is English' do
      it 'returns the English description' do
        Gitlab::I18n.with_locale(:en) do
          expect(translated_description)
            .to eq('Streamline code reviews by analyzing code changes, comments, and linked issues.')
        end
      end
    end

    context 'when the locale is not English' do
      it 'returns the translation description' do
        with_stubbed_translations(:fr, fr_translations) do
          expect(translated_description)
            .to eq('Code Review description in French')
        end
      end
    end
  end
end
