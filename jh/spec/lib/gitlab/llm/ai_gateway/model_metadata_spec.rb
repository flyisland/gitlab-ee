# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Llm::AiGateway::ModelMetadata, feature_category: :ai_abstraction_layer do
  let_it_be(:self_hosted_model) { create(:ai_self_hosted_model) }
  let_it_be(:self_hosted_feature_setting) { create(:ai_feature_setting, self_hosted_model: self_hosted_model) }

  let(:feature_setting) { self_hosted_feature_setting }
  let(:model_metadata) { described_class.new(feature_setting: feature_setting) }

  describe '#to_params' do
    subject(:to_params) { model_metadata.to_params }

    context 'when SAAS_LLM_ENDPOINT is configured' do
      let_it_be(:root_namespace) { create(:group) }
      let(:feature_name) { 'duo_chat' }
      let(:model_ref) { 'claude-3-7-sonnet-20250219' }

      let(:feature_setting) do
        create(
          :ai_namespace_feature_setting,
          namespace: root_namespace,
          feature: feature_name,
          offered_model_ref: model_ref
        )
      end

      let(:default_params) do
        {
          provider: 'gitlab',
          identifier: model_ref,
          feature_setting: 'duo_chat'
        }
      end

      before do
        allow(Gitlab).to receive(:com?).and_return(true)
        stub_env('SAAS_LLM_ENDPOINT', 'https://custom-ai-endpoint.com')
        stub_env('SAAS_LLM_API_KEY', 'test-api-key')
        stub_env('SAAS_LLM_PROVIDER', 'openai')
        stub_env('SAAS_LLM_NAME', 'gpt')
        stub_env('SAAS_LLM_IDENTIFIER', 'gpt-mini-4o')
      end

      it 'returns merged params with custom AI endpoint configuration' do
        expected_params = {
          provider: 'openai',
          identifier: 'gpt-mini-4o',
          feature_setting: 'duo_chat',
          endpoint: 'https://custom-ai-endpoint.com',
          api_key: 'test-api-key',
          name: 'gpt',
          raw_metadata: default_params
        }

        is_expected.to eq(expected_params)
      end

      context 'when default params is nil' do
        let(:feature_setting) { nil }

        before do
          allow(::Ai::AmazonQ).to receive(:connected?).and_return(false)
        end

        it 'returns custom model info with empty raw_metadata' do
          expected_params = {
            endpoint: 'https://custom-ai-endpoint.com',
            api_key: 'test-api-key',
            provider: 'openai',
            name: 'gpt',
            identifier: 'gpt-mini-4o',
            raw_metadata: {}
          }

          is_expected.to eq(expected_params)
        end
      end

      context 'with default environment values' do
        before do
          stub_env('SAAS_LLM_ENDPOINT', 'https://custom-ai-endpoint.com')
          stub_env('SAAS_LLM_API_KEY', 'test-api-key')
        end

        it 'uses default values for optional environment variables' do
          expected_params = {
            provider: 'openai',
            identifier: 'gpt-mini-4o',
            feature_setting: 'duo_chat',
            endpoint: 'https://custom-ai-endpoint.com',
            api_key: 'test-api-key',
            name: 'gpt',
            raw_metadata: default_params
          }

          is_expected.to eq(expected_params)
        end
      end
    end

    context 'when not on GitLab.com' do
      let(:feature_setting) { nil }

      before do
        allow(Gitlab).to receive(:com?).and_return(false)
        stub_env('SAAS_LLM_ENDPOINT', 'https://custom-ai-endpoint.com')
        stub_env('SAAS_LLM_API_KEY', 'test-api-key')
      end

      it 'falls back to super method behavior' do
        is_expected.to be_nil
      end
    end

    context 'when SAAS_LLM_ENDPOINT is not configured' do
      let(:feature_setting) { nil }

      before do
        allow(::Ai::AmazonQ).to receive(:connected?).and_return(false)
      end

      it 'falls back to super method behavior' do
        is_expected.to be_nil
      end
    end
  end
end
