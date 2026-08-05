# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Llm::AiGateway::Completions::FeatureDiscoverySearch, feature_category: :activation do
  let_it_be(:user) { build(:user) }
  let_it_be(:group) { build(:group) }

  let(:prompt_class) { nil }

  let(:prompt_message) do
    build(:ai_message, :feature_discovery_search, user: user, resource: group, request_id: 'uuid')
  end

  let(:query) { 'review code' }

  let(:catalogue) do
    [
      { id: 'project_merge_request_list', name: 'Merge requests', description: 'Review merge requests' },
      { id: 'pipelines', name: 'Pipelines', description: 'CI/CD pipelines' }
    ]
  end

  let(:options) { { query: query, features: catalogue, action: :feature_discovery_search } }
  # The AI Gateway wraps the model output under a "content" key.
  let(:content) { { 'feature_ids' => %w[project_merge_request_list pipelines] } }
  let(:response_body) { { content: content }.to_json }
  let(:response) { instance_double(HTTParty::Response, body: response_body, success?: true) }

  subject(:execute) { described_class.new(prompt_message, prompt_class, options).execute }

  before do
    allow_next_instance_of(Gitlab::Llm::AiGateway::Client) do |client|
      allow(client).to receive(:complete_prompt).and_return(response)
    end
  end

  describe '#execute' do
    it 'sends the query and catalogue as inputs' do
      expect_next_instance_of(Gitlab::Llm::AiGateway::Client) do |client|
        expect(client).to receive(:complete_prompt).with(
          a_hash_including(
            prompt_name: :feature_discovery_search,
            prompt_version: described_class::PROMPT_VERSION,
            inputs: { query: query, features: catalogue }
          )
        ).and_return(response)
      end

      execute
    end

    it 'returns the ordered feature ids parsed from the response' do
      expect(execute).to eq(%w[project_merge_request_list pipelines])
    end

    context 'when the model returns a bare array as content' do
      let(:content) { %w[pipelines project_merge_request_list] }

      it 'preserves the model order' do
        expect(execute).to eq(%w[pipelines project_merge_request_list])
      end
    end

    context 'when the model returns an unknown id' do
      let(:content) { { 'feature_ids' => %w[project_merge_request_list made_up_feature] } }

      it 'drops ids not present in the catalogue we sent' do
        expect(execute).to eq(%w[project_merge_request_list])
      end
    end

    context 'when the query is blank' do
      let(:query) { '  ' }

      it 'returns [] without calling the AI Gateway' do
        expect(Gitlab::Llm::AiGateway::Client).not_to receive(:new)
        expect(execute).to eq([])
      end
    end

    context 'when the catalogue is empty' do
      let(:catalogue) { [] }

      it 'returns [] without calling the AI Gateway' do
        expect(Gitlab::Llm::AiGateway::Client).not_to receive(:new)
        expect(execute).to eq([])
      end
    end

    context 'when the AI Gateway raises' do
      before do
        allow_next_instance_of(Gitlab::Llm::AiGateway::Client) do |client|
          allow(client).to receive(:complete_prompt).and_raise(StandardError)
        end
      end

      it 'tracks the error and degrades to []', :aggregate_failures do
        expect(Gitlab::ErrorTracking).to receive(:track_exception)
        expect(execute).to eq([])
      end
    end

    context 'when parsing the response raises' do
      let(:catalogue) do
        [
          { id: 'project_merge_request_list', name: 'Merge requests', description: 'Review merge requests' },
          'malformed_feature_entry'
        ]
      end

      it 'tracks the error and degrades to []', :aggregate_failures do
        expect(Gitlab::ErrorTracking).to receive(:track_exception)
        expect(execute).to eq([])
      end
    end
  end
end
