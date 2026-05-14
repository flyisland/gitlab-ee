# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ActiveContext::EmbeddingModelActivationService, feature_category: :global_search do
  let_it_be(:collection) { create(:ai_active_context_collection, :code_collection) }

  let(:model_ref) { 'text_embedding_005_vertex' }
  let(:dimensions) { 768 }
  let(:model_type) { nil }
  let(:expected_field_name) { 'embeddings_v1' }

  before do
    allow(Ai::ActiveContext::Collections::Code).to receive(:collection_record).and_return(collection)
  end

  subject(:service) do
    described_class.new(
      collection_class: Ai::ActiveContext::Collections::Code,
      model_ref: model_ref,
      dimensions: dimensions,
      model_type: model_type
    )
  end

  describe '#initialize' do
    it 'initializes successfully when collection_record exists' do
      expect(service).to be_a(described_class)
    end

    context 'when collection_record is blank' do
      before do
        allow(Ai::ActiveContext::Collections::Code).to receive(:collection_record).and_return(nil)
      end

      it 'raises InvalidError' do
        expect { service.execute! }.to raise_error(described_class::InvalidError, /collection_record not found/)
      end
    end
  end

  describe '#execute!' do
    let(:task_service) { instance_double(Ai::ActiveContext::TaskService) }

    before do
      allow(Ai::ActiveContext::TaskService).to receive(:new).and_return(task_service)
      allow(task_service).to receive(:create_chain)
      allow(collection).to receive(:update_metadata!)
    end

    it 'updates collection metadata with next_indexing_embedding_model' do
      service.execute!

      expect(collection).to have_received(:update_metadata!).with(
        next_indexing_embedding_model: {
          'model_type' => model_type,
          'model_ref' => model_ref,
          'field' => expected_field_name,
          'dimensions' => dimensions
        }
      )
    end

    context 'when no previous embedding model exists' do
      it 'creates a chain with AddEmbeddingsField and UpdateCollectionMetadata only' do
        service.execute!

        expect(task_service).to have_received(:create_chain).with(
          [Ai::ActiveContext::Tasks::AddEmbeddingsField, {
            'collection' => collection.name_without_prefix,
            'field' => expected_field_name,
            'dimensions' => dimensions
          }],
          [Ai::ActiveContext::Tasks::UpdateCollectionMetadata, {
            'collection' => collection.name_without_prefix,
            'metadata' => {
              'current_indexing_embedding_model' => hash_including('field' => expected_field_name),
              'search_embedding_model' => hash_including('field' => expected_field_name),
              'next_indexing_embedding_model' => nil
            }
          }]
        )
      end
    end

    context 'when previous embedding model exists' do
      let(:previous_field_name) { 'embeddings_v1' }
      let(:expected_field_name) { 'embeddings_v2' }
      let(:embedding_model) do
        instance_double(ActiveContext::EmbeddingModel, field: previous_field_name)
      end

      before do
        allow(Ai::ActiveContext::Collections::Code)
          .to receive(:current_indexing_embedding_model).and_return(embedding_model)
      end

      it 'creates a chain with all four tasks, using the new field for indexing and old field for nullification' do
        service.execute!

        expect(task_service).to have_received(:create_chain).with(
          [Ai::ActiveContext::Tasks::AddEmbeddingsField, {
            'collection' => collection.name_without_prefix,
            'field' => expected_field_name,
            'dimensions' => dimensions
          }],
          [Ai::ActiveContext::Tasks::BackfillEmbeddings, {
            'collection' => collection.name_without_prefix,
            'field' => expected_field_name
          }],
          [Ai::ActiveContext::Tasks::UpdateCollectionMetadata, {
            'collection' => collection.name_without_prefix,
            'metadata' => {
              'current_indexing_embedding_model' => hash_including('field' => expected_field_name),
              'search_embedding_model' => hash_including('field' => expected_field_name),
              'next_indexing_embedding_model' => nil
            }
          }],
          [Ai::ActiveContext::Tasks::NullifyField, {
            'collection' => collection.name_without_prefix,
            'field' => previous_field_name
          }]
        )
      end
    end

    context 'when model_type is provided' do
      let(:model_type) { 'vertex' }

      it 'includes model_type in the metadata passed to update_metadata!' do
        service.execute!

        expect(collection).to have_received(:update_metadata!).with(
          next_indexing_embedding_model: hash_including('model_type' => 'vertex')
        )
      end
    end

    context 'when next_indexing_embedding_model is already set' do
      before do
        allow(Ai::ActiveContext::Collections::Code).to receive(:next_indexing_embedding_model).and_return(
          {
            'model_ref' => 'text_embedding_004_vertex',
            'field' => 'embeddings_v1'
          }
        )
      end

      it 'raises InvalidError' do
        expect { service.execute! }.to raise_error(
          described_class::InvalidError, /next_indexing_embedding_model is already set/
        )
      end

      it 'does not update collection metadata' do
        expect { service.execute! }.to raise_error(described_class::InvalidError)
        expect(collection).not_to have_received(:update_metadata!)
      end

      it 'does not create task chain' do
        expect { service.execute! }.to raise_error(described_class::InvalidError)
        expect(task_service).not_to have_received(:create_chain)
      end
    end
  end
end
