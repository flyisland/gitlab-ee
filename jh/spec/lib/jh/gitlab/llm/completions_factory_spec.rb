# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::CompletionsFactory, feature_category: :ai_abstraction_layer do
  using RSpec::Parameterized::TableSyntax

  describe '.completion' do
    where(:ai_provider, :ai_action, :service_class) do
      :chat_glm | :explain_code | ::Gitlab::Llm::ChatGlm::Completions::ExplainCode
      :mini_max | :explain_code | ::Gitlab::Llm::MiniMax::Completions::ExplainCode
    end

    with_them do
      it 'override LLM service' do
        allow(::Gitlab::Llm::ClientFactory).to receive(:ai_provider).and_return(ai_provider)
        expect(described_class.completions[ai_action][:service_class]).to eq(service_class)
      end
    end
  end
end
