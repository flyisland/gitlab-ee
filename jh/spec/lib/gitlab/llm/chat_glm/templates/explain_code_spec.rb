# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Llm::ChatGlm::Templates::ExplainCode, feature_category: :source_code_management do
  let(:user_message) do
    {
      'role' => 'user',
      'content' => 'Hello'
    }
  end

  let(:messages) do
    [
      {
        'role' => 'system',
        'content' => 'You are a knowledgeable assistant explaining to an engineer'
      },
      user_message
    ]
  end

  describe '.get_options' do
    it 'returns correct parameters' do
      expect(described_class.get_options(messages)).to eq({
        content: [user_message],
        temperature: 0.3
      })
    end
  end
end
