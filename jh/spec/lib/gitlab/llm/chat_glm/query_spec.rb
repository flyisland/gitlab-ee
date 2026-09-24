# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::ChatGlm::Query, feature_category: :not_owned do # rubocop: disable  RSpec/InvalidFeatureCategory
  using RSpec::Parameterized::TableSyntax
  include_context 'with ChatGLM client shared context'

  let_it_be(:user) { create(:user) }

  describe "#chat" do
    where(:target_method, :prompt_message, :stub_chat_success, :response_body) do
      'chat_v3' | ref('prompt_v3') | 'stub_chat_v3_request' | ref('chat_v3_response_body')
      'chat'    | ref('prompt')    | 'stub_chat_request'    | ref('chat_response_body')
    end

    with_them do
      subject(:chat) do
        described_class.new(user).send(target_method, content: prompt_message, parsed_response: true)
      end

      before do
        send(stub_chat_success)
      end

      context 'without environments' do
        before do
          stub_env('CHAT_GLM_API_KEY' => nil)
        end

        it 'responses nil' do
          expect(chat).to be_nil
        end
      end

      context 'with environments' do
        before do
          stub_env('CHAT_GLM_API_KEY' => api_key)
        end

        it 'returns chat response' do
          expect(chat).to match response_body
        end
      end
    end
  end
end
