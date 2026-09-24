# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::MiniMax::ResponseModifiers::Chat, feature_category: :not_owned do # rubocop: disable  RSpec/InvalidFeatureCategory
  include_context 'with MiniMax client shared context'

  subject(:chat) { described_class.new(ai_response) }

  describe '#response_body' do
    let(:ai_response) { chat_response_body.to_json }

    it 'returns output text' do
      expect(chat.response_body).to eq "这句话的英文翻译是：Who am I?"
      expect(chat.errors).to eq []
    end
  end

  describe '#errors' do
    let(:ai_response) { failed_chat_response_body.to_json }

    it 'returns errors' do
      expect(chat.response_body).to be_blank
      expect(chat.errors).to eq [failed_chat_response_body.dig('base_resp', 'status_msg')]
    end
  end
end
