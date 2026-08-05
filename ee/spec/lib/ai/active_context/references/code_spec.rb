# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ActiveContext::References::Code, :aggregate_failures, feature_category: :code_suggestions do
  let(:collection) do
    create(:ai_active_context_collection, :code_collection)
  end

  let(:routing) { 1 }

  let(:identifier) { 'hash-id-123' }
  let(:reference) { described_class.new(collection_id: collection.id, routing: routing, args: identifier) }

  describe '#serialize' do
    it 'serializes correctly' do
      expect(reference.serialize).to eq("#{described_class}|#{collection.id}|#{routing}|#{identifier}")
    end
  end

  describe '#operation' do
    it 'is update' do
      expect(reference.operation).to eq(:update)
    end
  end

  describe '#jsons' do
    it 'contains the identifier and ref fields' do
      expect(reference.jsons).to eq([{ unique_identifier: identifier }])
    end
  end

  describe '.preprocessors' do
    it 'has preprocessing for getting content and generating embeddings' do
      expect(described_class.preprocessors.pluck(:name)).to eq([:get_content, :embeddings])
    end
  end

  describe '.preprocess_references' do
    let_it_be(:indexing_embedding_valid_value) do
      { model_ref: 'text_embedding_005_vertex', field: 'embeddings_v1' }
    end

    let(:expected_embeddings_generation_caller) { "ActiveContext::EmbeddingModel" }

    let_it_be(:collection) do
      create(:ai_active_context_collection, :code_collection).tap do |c|
        c.update_metadata!(current_indexing_embedding_model: indexing_embedding_valid_value)
      end
    end

    let(:identifier_1) { 'hash1' }
    let(:identifier_2) { 'hash2' }
    let(:reference_1) { described_class.new(collection_id: collection.id, routing: routing, args: identifier_1) }
    let(:reference_2) { described_class.new(collection_id: collection.id, routing: routing, args: identifier_2) }

    let(:refs) { [reference_1, reference_2] }

    let(:search_response) do
      [
        { 'id' => identifier_1, 'content' => 'content_1' },
        { 'id' => identifier_2, 'content' => 'content_2' }
      ]
    end

    let(:embedding_1) { [1, 2, 3] }
    let(:embedding_2) { [4, 5, 6] }

    before do
      allow(::ActiveContext::Logger).to receive(:info)

      allow(::ActiveContext).to receive_message_chain(:adapter, :search).and_return(search_response)
      allow(::ActiveContext).to receive_message_chain(:adapter, :full_collection_name)
        .and_return(ActiveContextHelpers.code_collection_name)

      allow_next_instance_of(::ActiveContext::EmbeddingModel) do |embedding_model|
        allow(embedding_model).to receive(:generate_embeddings).with(
          %w[content_1 content_2]
        ).and_return([embedding_1, embedding_2])
      end

      allow(described_class).to receive(:fetch_content).and_call_original
      allow(described_class).to receive(:apply_embeddings).and_call_original
    end

    it 'calls `fetch_content` with the correct references' do
      expect(described_class).to receive(:fetch_content).with(
        hash_including(refs: [reference_1, reference_2])
      ).and_call_original

      described_class.preprocess_references(refs)
    end

    it 'calls the apply embeddings method with the correct arguments' do
      expect(described_class).to receive(:apply_embeddings).and_wrap_original do |method, **kwargs|
        # references should have the updated content
        passed_refs = kwargs[:refs]
        expect(passed_refs).to eq([reference_1, reference_2])
        expect(passed_refs.first.documents.pluck(:content)).to eq(['content_1'])
        expect(passed_refs.second.documents.pluck(:content)).to eq(['content_2'])

        expect(kwargs[:infinite_retry_error_types]).to eq(
          [::Gitlab::Llm::Concerns::ExponentialBackoff::RateLimitError]
        )

        method.call(**kwargs)
      end

      described_class.preprocess_references(refs)
    end

    it 'has no failed refs' do
      result = described_class.preprocess_references(refs)
      expect(result[:failed]).to be_empty
    end

    it 'sets the contents and embeddings for each successful ref' do
      result = described_class.preprocess_references(refs)
      successful_refs = result[:successful]

      expect(successful_refs).to eq([reference_1, reference_2])
      expect(successful_refs.first.jsons).to eq(
        [
          {
            content: 'content_1',
            unique_identifier: identifier_1,
            embeddings_v1: embedding_1
          }
        ]
      )
      expect(successful_refs.second.jsons).to eq(
        [
          {
            content: 'content_2',
            unique_identifier: identifier_2,
            embeddings_v1: embedding_2
          }
        ]
      )
    end

    context 'when some refs do not have corresponding content' do
      let(:search_response) do
        [
          { 'id' => identifier_1, 'content' => 'content_1' }
        ]
      end

      before do
        allow_next_instance_of(::ActiveContext::EmbeddingModel) do |embedding_model|
          allow(embedding_model).to receive(:generate_embeddings).with(
            %w[content_1]
          ).and_return([embedding_1])
        end
      end

      it 'calls the apply embeddings method with the correct references' do
        expect(described_class).to receive(:apply_embeddings).and_wrap_original do |method, **kwargs|
          # references should have the updated content
          passed_refs = kwargs[:refs]
          expect(passed_refs).to eq([reference_1])
          expect(passed_refs.first.documents.pluck(:content)).to eq(['content_1'])

          method.call(**kwargs)
        end

        described_class.preprocess_references(refs)
      end

      it 'puts the refs in the correct groups' do
        expect(::ActiveContext::Logger).to receive(:retryable_exception)

        results = described_class.preprocess_references(refs)
        successful_refs = results[:successful]
        failed_refs = results[:failed]

        expect(successful_refs).to eq([reference_1])
        expect(successful_refs.first.jsons).to eq(
          [
            {
              content: 'content_1',
              unique_identifier: identifier_1,
              embeddings_v1: embedding_1
            }
          ]
        )

        expect(failed_refs).to eq([reference_2])
      end
    end

    context 'when the indexing embedding models are not set' do
      before do
        collection.reload.update_metadata!(current_indexing_embedding_model: nil)
      end

      it 'does not generate embeddings' do
        expect(::Gitlab::Llm::Embeddings::CodeEmbeddings).not_to receive(:new)

        result = described_class.preprocess_references(refs)
        successful_refs = result[:successful]
        failed_refs = result[:failed]

        expect(failed_refs).to be_empty

        expect(successful_refs).to eq([reference_1, reference_2])
        expect(successful_refs.first.jsons).to eq(
          [
            {
              content: 'content_1',
              unique_identifier: identifier_1
            }
          ]
        )
        expect(successful_refs.second.jsons).to eq(
          [
            {
              content: 'content_2',
              unique_identifier: identifier_2
            }
          ]
        )
      end
    end

    context 'when the llm class raises an error' do
      before do
        allow_next_instance_of(::ActiveContext::EmbeddingModel) do |embedding_model|
          allow(embedding_model).to receive(:generate_embeddings).and_raise(StandardError, 'Failure')
        end
      end

      it 'puts the refs in the correct groups' do
        expect(::ActiveContext::Logger).to receive(:retryable_exception)

        result = described_class.preprocess_references(refs)
        successful_refs = result[:successful]
        failed_refs = result[:failed]

        expect(successful_refs).to be_empty

        expect(failed_refs).to eq([reference_1, reference_2])
        expect(failed_refs.first.jsons).to eq(
          [
            {
              content: 'content_1',
              unique_identifier: identifier_1
            }
          ]
        )
        expect(failed_refs.second.jsons).to eq(
          [
            {
              content: 'content_2',
              unique_identifier: identifier_2
            }
          ]
        )
      end
    end

    describe 'next_model_only option' do
      before do
        collection.update_metadata!(
          next_indexing_embedding_model: { model_ref: 'text_embedding_006_vertex', field: 'embeddings_v2' }
        )
      end

      context 'with the option specified' do
        where(:next_model_only) { [true, false] }

        with_them do
          it 'passes the option to the apply_embeddings method' do
            expect(described_class).to receive(:apply_embeddings).with(
              hash_including(next_model_only: next_model_only)
            ).and_call_original

            described_class.preprocess_references(refs, next_model_only: next_model_only)
          end
        end
      end

      context 'when the option is not specified' do
        it 'defaults to false' do
          expect(described_class).to receive(:apply_embeddings).with(
            hash_including(next_model_only: false)
          ).and_call_original

          described_class.preprocess_references(refs)
        end
      end
    end
  end
end
