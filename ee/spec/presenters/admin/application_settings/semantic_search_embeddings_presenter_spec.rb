# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::ApplicationSettings::SemanticSearchEmbeddingsPresenter, feature_category: :global_search do
  let(:update_allowed_in_instance) { true }
  let(:user_has_update_permission) { true }

  let(:collection_record) do
    build(
      :ai_active_context_collection,
      :code_collection,
      metadata: {
        current_indexing_embedding_model: current_model,
        next_indexing_embedding_model: next_model
      }
    )
  end

  let(:current_model) do
    {
      field: 'embeddings_v1',
      model_type: 'gitlab_managed',
      model_ref: 'text_embedding_005_vertex',
      dimensions: 32
    }
  end

  let(:next_model) do
    {
      field: 'embeddings_v2',
      model_type: 'self_hosted',
      model_ref: "123",
      dimensions: 768
    }
  end

  subject(:presenter) do
    described_class.new(
      instance_allows_user_model_selection: update_allowed_in_instance,
      user_has_update_model_permissions: user_has_update_permission,
      collection_record: collection_record
    )
  end

  describe '#user_can_update_model?' do
    using RSpec::Parameterized::TableSyntax

    where(:update_allowed_in_instance, :user_has_update_permission, :expected_result) do
      false | false | false
      true  | false | false
      false | true  | false
      true  | true  | true
    end

    with_them do
      it 'returns the expected result' do
        expect(presenter.user_can_update_model?).to be(expected_result)
      end
    end
  end

  describe '#current_model' do
    before do
      allow(::Ai::ActiveContext::Embedding).to receive(:attach_model_name).with(current_model).and_return(
        current_model.merge(model_name: 'text-embedding-005 - Vertex')
      )
    end

    it 'returns the current model with the name attached' do
      expect(presenter.current_model.symbolize_keys).to eq(
        current_model.merge(model_name: 'text-embedding-005 - Vertex')
      )
    end
  end

  describe '#next_model' do
    before do
      allow(::Ai::ActiveContext::Embedding).to receive(:attach_model_name).with(next_model).and_return(
        next_model.merge(model_name: 'Embedding Model 1')
      )
    end

    it 'returns the next model with the name attached' do
      expect(presenter.next_model.symbolize_keys).to eq(
        next_model.merge(model_name: 'Embedding Model 1')
      )
    end
  end

  describe '#form_display_model' do
    context 'if update_params is not nil' do
      subject(:presenter) do
        described_class.new(
          instance_allows_user_model_selection: update_allowed_in_instance,
          user_has_update_model_permissions: user_has_update_permission,
          collection_record: collection_record,
          update_params: update_params
        )
      end

      let(:update_params) { { model_ref: 'some-ref', model_type: 'gitlab_managed', dimensions: 32 } }

      it 'returns the update_params' do
        expect(presenter.form_display_model).to eq(update_params)
      end
    end

    context 'if update_params is nil' do
      it 'returns the next_model' do
        expect(presenter.form_display_model).to match(
          hash_including(**next_model)
        )
      end

      context 'when collection does not have a next model' do
        let(:next_model) { nil }

        it 'returns the current_model' do
          expect(presenter.form_display_model).to match(
            hash_including(**current_model)
          )
        end
      end

      context 'when collection does not have indexing models' do
        let(:current_model) { nil }
        let(:next_model) { nil }

        it 'returns nil' do
          expect(presenter.form_display_model).to be_nil
        end
      end
    end
  end

  describe '#disable_inputs?' do
    context 'when collection does not have next model' do
      where(:user_can_update_model) do
        [false, true]
      end

      with_them do
        it 'checks the user permission' do
          allow(presenter).to receive_messages(
            user_can_update_model?: user_can_update_model,
            next_model: nil
          )

          expect(presenter.disable_inputs?).to be(!user_can_update_model)
        end
      end
    end

    context 'when collection has next model' do
      where(:user_can_update_model) do
        [false, true]
      end

      with_them do
        it 'returns true' do
          allow(presenter).to receive_messages(
            user_can_update_model?: user_can_update_model,
            next_model: next_model
          )

          expect(presenter.disable_inputs?).to be(true)
        end
      end
    end
  end

  describe '#tested_model_metadata_json' do
    subject(:presenter) do
      described_class.new(
        instance_allows_user_model_selection: update_allowed_in_instance,
        user_has_update_model_permissions: user_has_update_permission,
        collection_record: collection_record,
        tested_model_metadata: tested_model_metadata
      )
    end

    context 'if tested_model_metadata is not nil' do
      let(:tested_model_metadata) { { model_ref: 'some-ref', model_type: 'gitlab_managed', dimensions: 32 } }

      it 'returns the tested_model_metadata json' do
        expect(presenter.tested_model_metadata_json).to eq(tested_model_metadata.to_json)
      end
    end

    context 'if tested_model_metadata is nil' do
      let(:tested_model_metadata) { nil }

      it 'returns nil' do
        expect(presenter.tested_model_metadata_json).to be_nil
      end
    end
  end
end
