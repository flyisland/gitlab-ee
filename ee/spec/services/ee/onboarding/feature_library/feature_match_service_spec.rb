# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::FeatureLibrary::FeatureMatchService, feature_category: :activation do
  let_it_be(:user) { build(:user) }
  let_it_be(:group) { build(:group, developers: user) }

  let(:query) { 'review code' }
  let(:panel) { 'group' }
  let(:resource) { group }
  let(:catalogue) do
    [{ id: 'group_merge_request_list', name: 'Merge requests', description: 'Review merge requests' }]
  end

  let(:completion_class) { ::Gitlab::Llm::AiGateway::Completions::FeatureDiscoverySearch }

  subject(:result) do
    described_class.new(query: query, panel: panel, user: user, resource: resource).execute
  end

  before do
    allow(Onboarding::FeatureLibrary::TerminologyMap).to receive(:all).and_return(
      [{ 'term' => 'pipeline', 'feature_key' => 'pipelines', 'panels' => %w[project group] }]
    )
  end

  describe '#execute' do
    context 'when eligible' do
      before do
        stub_feature_flags(feature_discovery_gemini_search: user)
        allow(group).to receive(:trial_active?).and_return(true)
        allow_next_instance_of(Onboarding::FeatureLibrary::CatalogueBuilder) do |builder|
          allow(builder).to receive(:execute).and_return(catalogue)
        end
      end

      context 'when deterministic search already matches' do
        let(:query) { 'pipeline' }

        it 'returns the deterministic ids without calling the AI Gateway' do
          expect(completion_class).not_to receive(:new)
          expect(result).to eq(%w[pipelines])
        end
      end

      context 'when deterministic search finds nothing' do
        it 'sends the query plus catalogue to Gemini and returns the matched ids' do
          expect_next_instance_of(
            completion_class,
            an_instance_of(::Gitlab::Llm::AiMessage),
            nil,
            a_hash_including(action: :feature_discovery_search, query: query, features: catalogue)
          ) do |completion|
            expect(completion).to receive(:execute).and_return(%w[group_merge_request_list])
          end

          expect(result).to eq(%w[group_merge_request_list])
        end

        context 'when the catalogue is empty' do
          let(:catalogue) { [] }

          it 'returns [] without calling the AI Gateway' do
            expect(completion_class).not_to receive(:new)
            expect(result).to eq([])
          end
        end
      end
    end

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(feature_discovery_gemini_search: false)
      end

      it 'returns [] without calling the AI Gateway' do
        expect(completion_class).not_to receive(:new)
        expect(result).to eq([])
      end
    end

    context 'when the namespace is not on an active trial' do
      before do
        stub_feature_flags(feature_discovery_gemini_search: user)
        allow(group).to receive(:trial_active?).and_return(false)
      end

      it 'returns [] without calling the AI Gateway' do
        expect(completion_class).not_to receive(:new)
        expect(result).to eq([])
      end
    end

    context 'without a resource' do
      let(:resource) { nil }

      before do
        stub_feature_flags(feature_discovery_gemini_search: user)
      end

      it 'returns [] without calling the AI Gateway' do
        expect(completion_class).not_to receive(:new)
        expect(result).to eq([])
      end
    end
  end
end
