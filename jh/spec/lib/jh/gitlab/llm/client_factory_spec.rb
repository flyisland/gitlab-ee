# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::Llm::ClientFactory do
  before do
    # clear default value in test helper
    stub_env('JH_AI_PROVIDER', nil)
  end

  describe '.ai_provider' do
    context 'without ai_provider config' do
      it 'returns default provider' do
        expect(described_class.ai_provider).to eq described_class::DEFAULT_PROVIDER
      end
    end

    context 'with ai_provider config' do
      let(:ai_provider) { :open_ai }

      before do
        stub_env('JH_AI_PROVIDER', ai_provider)
      end

      it 'returns default provider' do
        expect(described_class.ai_provider).to eq ai_provider
      end
    end
  end

  describe '.client' do
    it 'returns Llm client class' do
      expect(described_class.client).to eq ::Gitlab::Llm::ChatGlm::Query

      expect(described_class.client(provider: :chat_glm)).to eq ::Gitlab::Llm::ChatGlm::Query
      expect(described_class.client(provider: :mini_max)).to eq ::Gitlab::Llm::MiniMax::Client
    end
  end
end
