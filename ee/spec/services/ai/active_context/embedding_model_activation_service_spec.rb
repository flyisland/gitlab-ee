# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ActiveContext::EmbeddingModelActivationService, feature_category: :global_search do
  let(:model_ref) { 'text_embedding_005_vertex' }
  let(:dimensions) { 768 }
  let(:model_type) { nil }
  let(:expected_field_name) { 'embeddings_v1' }

  subject(:service) do
    described_class.new(
      collection_class: Ai::ActiveContext::Collections::Code,
      model_ref: model_ref,
      dimensions: dimensions,
      model_type: model_type
    )
  end

  describe '#initialize' do
    it 'initializes successfully' do
      expect(service).to be_a(described_class)
    end
  end

  describe '#execute!' do
    shared_examples 'successfully tests and updates the collection model' do
      it 'tests the given model metadata and updates collection.next_indexing_embedding_model' do
        expect(Ai::ActiveContext::TestEmbeddingModelService).to receive(:new).with(
          collection_class: Ai::ActiveContext::Collections::Code,
          model_ref: model_ref,
          dimensions: dimensions,
          model_type: model_type
        )
        expect(test_model_service).to receive(:execute)

        service.execute!

        expect(collection.reload.next_indexing_embedding_model.symbolize_keys).to eq({
          model_type: model_type,
          model_ref: model_ref,
          field: expected_field_name,
          dimensions: dimensions
        })
      end
    end

    shared_examples 'fails pre-flight checks' do
      it 'raises an InvalidError and does not test and update the model' do
        expect(Ai::ActiveContext::TestEmbeddingModelService).not_to receive(:new)
        expect(task_service).not_to receive(:create_chain)

        expect { service.execute! }.to raise_error(
          described_class::InvalidError, expected_error_message
        ).and not_change { collection.reload.next_indexing_embedding_model }
      end
    end

    let_it_be(:collection) { create(:ai_active_context_collection, :code_collection) }
    let(:task_service) { instance_double(Ai::ActiveContext::TaskService) }
    let(:test_model_service) { instance_double(Ai::ActiveContext::TestEmbeddingModelService) }
    let(:test_model_response) { ServiceResponse.success }

    before do
      allow(Ai::ActiveContext::TaskService).to receive(:new).and_return(task_service)
      allow(task_service).to receive(:create_chain)

      allow(Ai::ActiveContext::TestEmbeddingModelService).to receive(:new).and_return(test_model_service)
      allow(test_model_service).to receive(:execute).and_return(test_model_response)

      collection.reload
      allow(collection).to receive(:update_metadata!).and_call_original
      allow(Ai::ActiveContext::Collections::Code).to receive(:collection_record).and_return(collection)
    end

    it_behaves_like 'successfully tests and updates the collection model'

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

      context 'when task chain creation fails' do
        before do
          allow(Ai::ActiveContext::TaskService).to receive(:new).and_call_original
          allow(Ai::ActiveContext::Task).to receive(:create!)
            .and_raise(ActiveRecord::RecordInvalid)
        end

        it 'raises and UpdateFailed error and reverts the model metadata update' do
          expect(collection.reload.next_indexing_embedding_model).to be_nil
          expect(collection).to receive(:update_metadata!).with(
            next_indexing_embedding_model: {
              'model_type' => model_type,
              'model_ref' => model_ref,
              'field' => expected_field_name,
              'dimensions' => dimensions
            }
          )

          expect { service.execute! }.to raise_error(
            described_class::UpdateFailed, 'Record invalid'
          )

          expect(collection.reload.next_indexing_embedding_model).to be_nil
        end
      end
    end

    context 'when previous embedding model exists' do
      let(:previous_model_type) { nil }
      let(:previous_model_ref) { 'mock_embedding_001' }
      let(:previous_field_name) { 'embeddings_v1' }
      let(:expected_field_name) { 'embeddings_v2' }

      before do
        collection.reload.update_metadata!(
          current_indexing_embedding_model: {
            model_type: previous_model_type,
            model_ref: previous_model_ref,
            dimensions: dimensions,
            field: previous_field_name
          }
        )
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

      context 'when the update params are exactly the same as the current model' do
        let(:previous_model_ref) { 'text_embedding_005_vertex' }

        it_behaves_like 'fails pre-flight checks' do
          let(:expected_error_message) { 'the given model metadata is the same as the current model' }
        end

        context 'when model_type is present' do
          let(:previous_model_type) { 'gitlab_managed' }
          let(:model_type) { 'gitlab_managed' }

          it_behaves_like 'fails pre-flight checks' do
            let(:expected_error_message) { 'the given model metadata is the same as the current model' }
          end
        end
      end
    end

    context 'when unsupported dimensions value is provided' do
      let(:dimensions) { 0 }

      it 'raises UpdateFailed and does not create a task chain' do
        expect(collection).to receive(:update_metadata!).with(
          next_indexing_embedding_model: hash_including('dimensions' => 0)
        )
        expect(task_service).not_to receive(:create_chain)

        expect { service.execute! }.to raise_error(
          described_class::UpdateFailed,
          "Ai::ActiveContext::Collection - " \
            "Validation failed: Metadata must be a valid json schema"
        )
      end
    end

    context 'when unsupported model_ref is provided' do
      let(:model_ref) { 'test_model_001' }

      it_behaves_like 'fails pre-flight checks' do
        let(:expected_error_message) { "the given model_ref 'test_model_001' is not supported" }
      end
    end

    context 'when model_type=gitlab_managed' do
      let(:model_type) { 'gitlab_managed' }

      it_behaves_like 'successfully tests and updates the collection model'

      context 'when unsupported model_ref is provided' do
        let(:model_ref) { 'test_model_001' }

        it_behaves_like 'fails pre-flight checks' do
          let(:expected_error_message) { "the given model_ref 'test_model_001' is not supported" }
        end
      end
    end

    context 'when model_type=self_hosted' do
      let(:model_type) { 'self_hosted' }
      let(:model_ref) { self_hosted_embedding_model.id.to_s }

      context 'with an embedding self-hosted model' do
        let_it_be(:self_hosted_embedding_model) do
          create(:ai_self_hosted_model, :embedding, name: 'Embedding Model 1')
        end

        it_behaves_like 'successfully tests and updates the collection model'
      end

      context 'when a non-embedding self-hosted model is provided' do
        let_it_be(:self_hosted_general_model) do
          create(:ai_self_hosted_model, :general, name: 'General Model')
        end

        let(:model_ref) { self_hosted_general_model.id.to_s }

        it_behaves_like 'fails pre-flight checks' do
          let(:expected_error_message) { "the given model_ref '#{self_hosted_general_model.id}' is not supported" }
        end
      end

      context 'when the provided model_ref is not for a self-hosted model' do
        let(:model_ref) { 'text_embedding_005_vertex' }

        it_behaves_like 'fails pre-flight checks' do
          let(:expected_error_message) { "the given model_ref 'text_embedding_005_vertex' is not supported" }
        end
      end
    end

    context 'when unsupported model_type is provided' do
      let(:model_type) { 'gitlab' }

      it 'raises UpdateFailed and does not update the embedding model' do
        expect { service.execute! }.to raise_error(
          described_class::UpdateFailed,
          "Ai::ActiveContext::Collection - Validation failed: " \
            "Metadata must be a valid json schema"
        ).and not_change { collection.reload.next_indexing_embedding_model }
      end
    end

    context 'when next_indexing_embedding_model is already set' do
      before do
        collection.reload.update_metadata!(
          next_indexing_embedding_model: {
            model_ref: model_ref,
            dimensions: dimensions,
            field: 'embeddings_v1'
          }
        )
      end

      it 'raises InvalidError' do
        expect { service.execute! }.to raise_error(
          described_class::InvalidError, /next_indexing_embedding_model is already set/
        )
      end

      it 'does not update collection metadata' do
        expect(collection).not_to receive(:update_metadata!)
        expect { service.execute! }.to raise_error(described_class::InvalidError)
      end

      it 'does not create task chain' do
        expect { service.execute! }.to raise_error(described_class::InvalidError)
        expect(task_service).not_to have_received(:create_chain)
      end
    end

    context 'when collection_record is blank' do
      before do
        allow(Ai::ActiveContext::Collections::Code).to receive(:collection_record).and_return(nil)
      end

      it 'raises InvalidError' do
        expect { service.execute! }.to raise_error(described_class::InvalidError, /collection_record not found/)
      end
    end

    context 'when embeddings request test fails' do
      let(:test_model_response) { ServiceResponse.error(message: 'some error') }

      it 'raises InvalidError and does not update the embedding model' do
        expect { service.execute! }.to raise_error(
          described_class::InvalidError,
          "test embeddings request failed: some error"
        ).and not_change { collection.reload.next_indexing_embedding_model }
      end
    end

    context 'when embeddings request testing is skipped' do
      subject(:service) do
        described_class.new(
          collection_class: Ai::ActiveContext::Collections::Code,
          model_ref: model_ref,
          dimensions: dimensions,
          model_type: model_type,
          skip_embeddings_request_test: true
        )
      end

      it 'does not perform embeddings request testing' do
        expect(Ai::ActiveContext::TestEmbeddingModelService).not_to receive(:new)

        service.execute!

        expect(collection.reload.next_indexing_embedding_model.symbolize_keys).to include(
          model_type: model_type,
          model_ref: model_ref,
          dimensions: dimensions
        )
      end
    end
  end
end
