# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Llm::AiGateway::AgentPlatform::ModelMetadata, feature_category: :duo_agent_platform do
  let(:feature_setting) { build(:ai_feature_setting, :duo_agent_platform) }
  let(:service) { described_class.new(feature_setting: feature_setting) }
  let(:header_key) { ::Gitlab::Llm::AiGateway::AgentPlatform::ModelMetadata::HEADER_KEY }

  describe '#execute' do
    subject(:execute) { service.execute }

    context 'when not on Gitlab.com' do
      before do
        allow(::Gitlab).to receive(:com?).and_return(false)
        allow_next_instance_of(::Gitlab::Llm::AiGateway::ModelMetadata) do |metadata|
          allow(metadata).to receive(:to_params).and_return({ 'name' => 'original-model' })
        end
      end

      it 'calls super and returns parent result' do
        result = execute
        parsed_metadata = Gitlab::Json.parse(result[header_key])
        expect(parsed_metadata['name']).to eq('original-model')
      end
    end

    context 'when on Gitlab.com' do
      before do
        allow(::Gitlab).to receive(:com?).and_return(true)
      end

      context 'when SAAS_LLM_ENDPOINT is not set' do
        before do
          stub_env('SAAS_LLM_ENDPOINT', nil)
          allow_next_instance_of(::Gitlab::Llm::AiGateway::ModelMetadata) do |metadata|
            allow(metadata).to receive(:to_params).and_return({ 'name' => 'original-model' })
          end
        end

        it 'calls super and returns parent result' do
          result = execute
          parsed_metadata = Gitlab::Json.parse(result[header_key])
          expect(parsed_metadata['name']).to eq('original-model')
        end
      end

      context 'when SAAS_LLM_ENDPOINT is set' do
        before do
          stub_env('SAAS_LLM_ENDPOINT', 'https://custom-endpoint.com')
        end

        context 'when parent class returns empty result' do
          before do
            allow_next_instance_of(::Gitlab::Llm::AiGateway::ModelMetadata) do |metadata|
              allow(metadata).to receive(:to_params).and_return(nil)
            end
          end

          it 'returns result with default values' do
            result = execute
            parsed_metadata = Gitlab::Json.parse(result[header_key])

            expect(parsed_metadata).to include(
              'endpoint' => 'https://custom-endpoint.com',
              'api_key' => nil,
              'provider' => 'openai',
              'name' => 'gpt',
              'identifier' => 'pro-deepseek-v3'
            )
          end
        end

        context 'when parent class returns result with model metadata' do
          let(:original_metadata) do
            {
              'provider' => 'gitlab',
              'name' => 'claude-3-sonnet',
              'identifier' => 'claude-3-7-sonnet-20250219'
            }
          end

          before do
            allow_next_instance_of(::Gitlab::Llm::AiGateway::ModelMetadata) do |metadata|
              allow(metadata).to receive(:to_params).and_return(original_metadata)
            end
          end

          context 'without additional environment variables set' do
            it 'merges default values into the metadata' do
              result = execute
              parsed_metadata = Gitlab::Json.parse(result[header_key])

              expect(parsed_metadata).to include(
                'provider' => 'openai',
                'name' => 'gpt',
                'identifier' => 'pro-deepseek-v3',
                'endpoint' => 'https://custom-endpoint.com',
                'api_key' => nil
              )
            end

            it 'overrides original metadata with default values' do
              result = execute
              parsed_metadata = Gitlab::Json.parse(result[header_key])

              expect(parsed_metadata['provider']).to eq('openai')
              expect(parsed_metadata['name']).to eq('gpt')
              expect(parsed_metadata['identifier']).to eq('pro-deepseek-v3')
            end
          end

          context 'with all environment variables set' do
            before do
              stub_env('SAAS_LLM_PROVIDER', 'anthropic')
              stub_env('SAAS_LLM_NAME', 'custom-gpt')
              stub_env('SAAS_LLM_IDENTIFIER', 'custom-model-v2')
              stub_env('SAAS_LLM_API_KEY', 'secret-api-key')
            end

            it 'merges environment variable values into the metadata' do
              result = execute
              parsed_metadata = Gitlab::Json.parse(result[header_key])

              expect(parsed_metadata).to include(
                'provider' => 'anthropic',
                'name' => 'custom-gpt',
                'identifier' => 'custom-model-v2',
                'endpoint' => 'https://custom-endpoint.com',
                'api_key' => 'secret-api-key'
              )
            end

            it 'overrides original metadata with environment variables' do
              result = execute
              parsed_metadata = Gitlab::Json.parse(result[header_key])

              expect(parsed_metadata['provider']).to eq('anthropic')
              expect(parsed_metadata['name']).to eq('custom-gpt')
              expect(parsed_metadata['identifier']).to eq('custom-model-v2')
            end
          end

          context 'with partial environment variables set' do
            before do
              stub_env('SAAS_LLM_NAME', 'custom-gpt')
              stub_env('SAAS_LLM_API_KEY', 'secret-api-key')
              # SAAS_LLM_PROVIDER and SAAS_LLM_IDENTIFIER not set
            end

            it 'uses environment variables where available and defaults otherwise' do
              result = execute
              parsed_metadata = Gitlab::Json.parse(result[header_key])

              expect(parsed_metadata).to include(
                'provider' => 'openai', # default
                'name' => 'custom-gpt', # from env
                'identifier' => 'pro-deepseek-v3', # default
                'endpoint' => 'https://custom-endpoint.com',
                'api_key' => 'secret-api-key' # from env
              )
            end
          end
        end
      end
    end
  end
end
