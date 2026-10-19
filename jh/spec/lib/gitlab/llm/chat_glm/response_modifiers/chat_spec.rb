# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::ChatGlm::ResponseModifiers::Chat, feature_category: :source_code_management do
  include_context 'with ChatGLM client shared context'

  subject(:chat) { described_class.new(ai_response) }

  describe '#response_body' do
    let(:ai_response) { chat_response_body.to_json }

    it 'returns output text' do
      expect(chat.response_body).to eq chat_response_body['data']['outputText']
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
