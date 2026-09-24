# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::ChatGlm::ResponseModifiers::ChatV3, feature_category: :not_owned do # rubocop: disable  RSpec/InvalidFeatureCategory
  include_context 'with ChatGLM client shared context'

  subject(:chat) { described_class.new(ai_response) }

  describe '#response_body' do
    let(:ai_response) { chat_v3_response_body.to_json }

    it 'returns output text' do
      expect(chat.response_body).to eq "我是 ChatGLM，一个基于人工智能的语言模型。\n很高兴能和你聊天。你想聊些什么呢？"
      expect(chat.errors).to eq []
    end
  end

  describe '#errors' do
    let(:ai_response) { failed_chat_response_body.to_json }

    it 'returns errors' do
      expect(chat.response_body).to be_nil
      expect(chat.errors).to eq [failed_chat_response_body['msg']]
    end
  end
end
