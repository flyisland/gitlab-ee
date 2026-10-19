# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::ChatGlm::Client, feature_category: :not_owned do # rubocop: disable  RSpec/InvalidFeatureCategory
  using RSpec::Parameterized::TableSyntax
  include_context 'with ChatGLM client shared context'

  let(:client) { described_class.new(api_key: api_key) }

  describe '#chat' do
    where(:target_method, :prompt_message, :stub_chat_success, :response_body, :stub_chat_fail) do
      [
        ['chat_v3', ref('prompt_v3'), 'stub_chat_v3_request', ref('chat_v3_response_body'),
          'stub_failed_chat_v3_request'],
        ['chat', ref('prompt'), 'stub_chat_request', ref('chat_response_body'), 'stub_failed_chat_request']
      ]
    end

    with_them do
      let(:parsed_response) { client.send(target_method, prompt: prompt_message, parsed_response: true) }
      let(:body_response) { client.send(target_method, prompt: prompt_message, parsed_response: false) }

      context 'with invalid config' do
        let(:api_key) { 'invalid_format' }

        it 'raises an error' do
          expect { client }.to raise_error described_class::Error
        end
      end

      context 'with successful response' do
        before do
          send(stub_chat_success)
        end

        it 'sends request to engines' do
          expect(parsed_response).to match response_body
          expect(::Gitlab::Json.parse(body_response)).to match response_body
        end
      end

      context 'with failed chat response' do
        before do
          send(stub_chat_fail)
        end

        it 'sends request to engines' do
          expect(parsed_response).to match failed_chat_response_body
        end
      end
    end
  end
end
