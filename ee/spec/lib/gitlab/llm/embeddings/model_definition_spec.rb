# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::Llm::Embeddings::ModelDefinition, feature_category: :code_suggestions do
  describe '.for_gitlab_provided_code_embeddings' do
    it 'builds the expected model definition' do
      model_definition = described_class.for_gitlab_provided_code_embeddings(
        identifier: 'embedding_001',
        use_cloud_aigw: false
      )

      expect(model_definition.feature_name).to eq(:embeddings_code)
      expect(model_definition.unit_primitive).to eq('generate_embeddings_codebase')
      expect(model_definition.provider).to eq('gitlab')
      expect(model_definition.identifier).to eq('embedding_001')
      expect(model_definition.use_cloud_aigw).to be(false)
    end
  end

  describe 'model definition object' do
    let(:feature_name) { :some_feature }
    let(:unit_primitive) { 'some_unit_primitive' }
    let(:provider) { 'openai' }
    let(:identifier) { 'openai/embeddings_001' }
    let(:use_cloud_aigw) { false }

    let(:model_definition) do
      described_class.new(
        feature_name: feature_name,
        unit_primitive: unit_primitive,
        provider: provider,
        identifier: identifier,
        use_cloud_aigw: use_cloud_aigw
      )
    end

    describe '#aigw_base_url' do
      before do
        allow(::Gitlab::AiGateway).to receive_messages(
          url: 'https://default-aigw',
          cloud_connector_url: 'https://cloud-aigw'
        )
      end

      subject(:aigw_base_url) { model_definition.aigw_base_url }

      context 'when `use_cloud_aigw` is false' do
        let(:use_cloud_aigw) { false }

        it { is_expected.to eq('https://default-aigw') }
      end

      context 'when `use_cloud_aigw` is true' do
        let(:use_cloud_aigw) { true }

        it { is_expected.to eq('https://cloud-aigw') }
      end
    end

    describe '#model_params' do
      it 'returns the expected model parameters for AIGW' do
        expect(model_definition.model_params).to eq(
          {
            provider: provider,
            identifier: identifier
          }
        )
      end
    end

    describe '#gitlab_managed?' do
      subject(:gitlab_managed) { model_definition.gitlab_managed? }

      context "when provider is 'gitlab'" do
        let(:provider) { 'gitlab' }

        it { is_expected.to be true }
      end

      context "when provider is not 'gitlab'" do
        let(:provider) { 'openai' }

        it { is_expected.to be false }
      end
    end

    describe 'token limit exceeded error handling' do
      context 'when model does not catch errors' do
        let(:identifier) { 'some_identifier' }

        it 'return the expected values for error-handling methods' do
          expect(model_definition.catch_token_limit_exceeded_errors?).to be(false)
          expect(model_definition.token_limit_exceeded_message_pattern).to be_nil
        end
      end

      context 'when model should catch errors' do
        let(:identifier) { 'text_embedding_005_vertex' }

        it 'return the expected values for error-handling methods' do
          expect(model_definition.catch_token_limit_exceeded_errors?).to be(true)
          expect(model_definition.token_limit_exceeded_message_pattern).to eq(
            /the input token count is \d+ but the model supports up to \d+/
          )
        end
      end
    end
  end
end
