# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Llm::MiniMax::Templates::ExplainCode, feature_category: :source_code_management do
  let(:messages) do
    [
      {
        'role' => 'system',
        'content' => 'You are a knowledgeable assistant explaining to an engineer'
      },
      {
        'role' => 'user',
        'content' => 'Hello'
      },
      {
        'role' => 'assistant',
        'content' => 'Hello, two'
      },
      {
        'role' => 'user',
        'content' => 'Hello, three'
      },
      {
        'role' => 'wrong role',
        'content' => 'Hello, three'
      }
    ]
  end

  describe '.get_options' do
    it 'returns correct parameters' do
      expect(described_class.get_options(messages)).to eq({
        messages: [{
          sender_type: "BOT",
          sender_name: "JIHU_BOT",
          text: "You are a knowledgeable assistant explaining to an engineer"
        },
          {
            sender_type: "USER",
            sender_name: "user",
            text: "Hello"
          },
          {
            sender_type: "BOT",
            sender_name: "JIHU_BOT",
            text: "Hello, two"
          },
          {
            sender_type: "USER",
            sender_name: "user",
            text: "Hello, three"
          }],
        bot_setting: [
          {
            bot_name: "JIHU_BOT",
            content: "你是一个软件研发专家，请帮助我解释代码的相关问题"
          }
        ],
        temperature: 0.3
      })
    end
  end
end
