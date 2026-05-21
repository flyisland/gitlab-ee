# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ActiveContext::Embeddings::ModelSelector, feature_category: :code_suggestions do
  shared_context 'on saas instance' do
    before do
      stub_saas_features(gitlab_com_subscriptions: true)
      allow(::Gitlab::CurrentSettings).to receive(:gitlab_dedicated_instance?).and_return(false)
      allow(::Gitlab::AiGateway).to receive(:has_self_hosted_ai_gateway?).and_return(false)
    end
  end

  shared_context 'on dedicated instance' do
    before do
      stub_saas_features(gitlab_com_subscriptions: false)
      allow(::Gitlab::CurrentSettings).to receive(:gitlab_dedicated_instance?).and_return(true)
      allow(::Gitlab::AiGateway).to receive(:has_self_hosted_ai_gateway?).and_return(false)
    end
  end

  shared_context 'on SM instance without self-hosted AIGW' do
    before do
      stub_saas_features(gitlab_com_subscriptions: false)
      allow(::Gitlab::CurrentSettings).to receive(:gitlab_dedicated_instance?).and_return(false)
      allow(::Gitlab::AiGateway).to receive(:has_self_hosted_ai_gateway?).and_return(false)
    end
  end

  shared_context 'on SM instance with self-hosted AIGW' do
    before do
      stub_saas_features(gitlab_com_subscriptions: false)
      allow(::Gitlab::CurrentSettings).to receive(:gitlab_dedicated_instance?).and_return(false)
      allow(::Gitlab::AiGateway).to receive(:has_self_hosted_ai_gateway?).and_return(true)
    end
  end

  describe '.use_gitlab_selected_model?' do
    subject(:use_gitlab_selected_model) { described_class.use_gitlab_selected_model? }

    context 'on saas instance' do
      include_context 'on saas instance'

      it { is_expected.to be(true) }
    end

    context 'on dedicated instance' do
      include_context 'on dedicated instance'

      it { is_expected.to be(true) }
    end

    context 'on SM instance without self-hosted AIGW' do
      include_context 'on SM instance without self-hosted AIGW'

      it { is_expected.to be(true) }
    end

    context 'on SM instance with self-hosted AIGW' do
      include_context 'on SM instance with self-hosted AIGW'

      it { is_expected.to be(false) }
    end
  end

  describe '.user_can_select_model?' do
    subject(:user_can_select_model) { described_class.user_can_select_model? }

    context 'on saas instance' do
      include_context 'on saas instance'

      it { is_expected.to be(false) }
    end

    context 'on dedicated instance' do
      include_context 'on dedicated instance'

      it { is_expected.to be(false) }
    end

    context 'on SM instance without self-hosted AIGW' do
      include_context 'on SM instance without self-hosted AIGW'

      it { is_expected.to be(false) }
    end

    context 'on SM instance with self-hosted AIGW' do
      include_context 'on SM instance with self-hosted AIGW'

      it { is_expected.to be(true) }

      it 'returns false when semantic_search_user_model_selection FF is disabled' do
        stub_feature_flags(semantic_search_user_model_selection: false)

        expect(user_can_select_model).to be(false)
      end
    end
  end

  describe '.for' do
    subject(:embedding_model) { described_class.for(model_metadata) }

    let(:model_metadata) { nil }

    shared_examples 'returns nil if model_metadata is not set' do
      context 'when model_metadata is nil' do
        let(:model_metadata) { nil }

        it 'returns nil' do
          expect(embedding_model).to be_nil
        end
      end
    end

    shared_examples 'requires `model_ref` and `field` metadata' do
      context 'when model_metadata[:model_ref] is not set' do
        let(:model_metadata) { { field: 'test_embeddings_field' } }

        it 'raises an error' do
          expect { embedding_model }.to raise_error(
            described_class::UnexpectedModelConfiguration,
            "`model_metadata` must have a `model_ref` and `field`"
          )
        end
      end

      context 'when model_metadata[:field] is not set' do
        let(:model_metadata) { { model_ref: 'model_001_reference' } }

        it 'raises an error' do
          expect { embedding_model }.to raise_error(
            described_class::UnexpectedModelConfiguration,
            "`model_metadata` must have a `model_ref` and `field`"
          )
        end
      end
    end

    shared_examples 'gitlab-managed model' do
      context 'when model_metadata has the required values' do
        before do
          stub_const("::Ai::ActiveContext::Embedding::MODELS_LOOKUP", models_lookup)
        end

        let(:models_lookup) { {} }

        it 'raises an error if model_ref is not in the MODELS_LOOKUP' do
          expect { embedding_model }.to raise_error(
            described_class::MissingModelDefinition,
            "Missing definitions for Gitlab-managed model: model_001_reference"
          )
        end

        context 'when model_ref is in the MODELS_LOOKUP' do
          let(:models_lookup) do
            {
              'model_001_reference' => { batch_size: 3 }
            }
          end

          it 'returns the expected gitlab-selected model' do
            expect(embedding_model).to be_a(::ActiveContext::EmbeddingModel)
            expect(embedding_model.model_key).to eq("gitlab_managed__model_001_reference")
            expect(embedding_model.field).to eq(:test_embeddings_field)

            expect(embedding_model.llm_class).to eq(::Gitlab::Llm::Embeddings::CodeEmbeddings)

            expect(embedding_model.llm_params).to match(
              batch_size: 3,
              search: false,
              model_definition: be_a(::Gitlab::Llm::Embeddings::ModelDefinition)
            )

            llm_model_definition = embedding_model.llm_params[:model_definition]
            expect(llm_model_definition.feature_name).to eq(:embeddings_code)
            expect(llm_model_definition.unit_primitive).to eq(
              ::Gitlab::Llm::Embeddings::ModelDefinition::UNIT_PRIMITIVE_GENERATE_EMBEDDINGS_CODEBASE
            )
            expect(llm_model_definition.provider).to eq('gitlab')
            expect(llm_model_definition.identifier).to eq('model_001_reference')
            expect(llm_model_definition.use_cloud_aigw).to be(expected_use_cloud_aigw_value)
          end

          context 'for search embedding model' do
            subject(:embedding_model) { described_class.for(model_metadata, search: true) }

            it 'sets LLM parameter search=true' do
              expect(embedding_model.llm_class).to eq(::Gitlab::Llm::Embeddings::CodeEmbeddings)

              expect(embedding_model.llm_params).to match(
                batch_size: 3,
                search: true,
                model_definition: be_a(::Gitlab::Llm::Embeddings::ModelDefinition)
              )
            end
          end
        end
      end
    end

    shared_examples 'gitlab selects the model' do
      it_behaves_like 'returns nil if model_metadata is not set'
      it_behaves_like 'requires `model_ref` and `field` metadata'

      it_behaves_like 'gitlab-managed model' do
        let(:model_metadata) { { model_ref: 'model_001_reference', field: 'test_embeddings_field' } }
        let(:expected_use_cloud_aigw_value) { false }
      end
    end

    context 'on saas instance' do
      include_context 'on saas instance'

      it_behaves_like 'gitlab selects the model'
    end

    context 'on dedicated instance' do
      include_context 'on dedicated instance'

      it_behaves_like 'gitlab selects the model'
    end

    context 'on SM instance without self-hosted AIGW' do
      include_context 'on SM instance without self-hosted AIGW'

      it_behaves_like 'gitlab selects the model'
    end

    context 'on SM instance with self-hosted AIGW' do
      include_context 'on SM instance with self-hosted AIGW'

      it_behaves_like 'returns nil if model_metadata is not set'
      it_behaves_like 'requires `model_ref` and `field` metadata'

      context 'when model_metadata[:model_type] is nil' do
        let(:model_metadata) { { model_ref: 'model_001_reference', field: 'test_embeddings_field' } }

        it 'raises an error' do
          expect { embedding_model }.to raise_error(
            described_class::UnexpectedModelConfiguration,
            "`model_metadata` must have a `model_type` if Duo Self-Hosted is configured"
          )
        end
      end

      context 'when model_metadata[:model_type] is `gitlab_managed`' do
        it_behaves_like 'gitlab-managed model' do
          let(:model_metadata) do
            { model_ref: 'model_001_reference', field: 'test_embeddings_field', model_type: 'gitlab_managed' }
          end

          let(:expected_use_cloud_aigw_value) { true }
        end
      end

      context 'when model_metadata[:model_type] is `self_hosted`' do
        let(:model_metadata) do
          { model_ref: 'model_001_reference', field: 'test_embeddings_field', model_type: 'self_hosted' }
        end

        it 'returns the expected self-hosted model'
      end

      context 'when model_metadata[:model_type] is not supported' do
        let(:model_metadata) do
          { model_ref: 'model_001_reference', field: 'test_embeddings_field', model_type: 'dummy' }
        end

        it 'raises an error' do
          expect { embedding_model }.to raise_error(
            described_class::UnsupportedModelConfiguration,
            "Unsupported `model_type` value: dummy"
          )
        end
      end
    end
  end
end
