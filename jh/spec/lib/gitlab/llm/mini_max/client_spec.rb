# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::MiniMax::Client, feature_category: :ai_abstraction_layer do
  include_context 'with MiniMax client shared context'

  let(:client) { described_class.new('user') }
  let(:parsed_response) { client.chat(**prompt, parsed_response: true) }
  let(:body_response) { client.chat(**prompt, parsed_response: false) }

  before do
    stub_env('CHAT_MINIMAX_GROUP_ID', group_id)
    stub_env('CHAT_MINIMAX_API_KEY', api_key)
  end

  describe '#initialize' do
    it 'raise error when no group id and api_key' do
      stub_env('CHAT_MINIMAX_GROUP_ID', nil)
      stub_env('CHAT_MINIMAX_API_KEY', nil)
      expect { client }.to raise_error(described_class::Error, 'invalid configuration')
    end
  end

  describe '#chat' do
    context 'with successful response' do
      it 'sends request to engines' do
        stub_chat_request
        expect(parsed_response).to match chat_response_body
        expect(::Gitlab::Json.parse(body_response)).to match chat_response_body
      end

      it 'send request with content params' do
        stub_request(:post, chat_url)
          .with(body: /"messages":/,
            headers: { 'Content-Type': 'application/json', Authorization: "Bearer #{api_key}" })
          .and_return stub_response(chat_response_body)

        modified_prompt = prompt.deep_dup
        modified_prompt[:content] = modified_prompt.delete('messages')

        expect(::Gitlab::Json.parse(client.chat(**modified_prompt, parsed_response: false))).to match chat_response_body
      end
    end

    context 'with failed chat response' do
      it 'sends request to engines' do
        stub_failed_chat_request
        expect(parsed_response).to match failed_chat_response_body
      end
    end
  end
end
