# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::ApplicationSettings::SemanticSearchEmbeddingsController, :enable_admin_mode, feature_category: :global_search do
  let_it_be(:user) { create(:user) }
  let_it_be(:admin) { create(:admin) }

  before do
    allow(admin).to receive(:can?).and_call_original
  end

  shared_examples 'redirects logged-out users' do
    context 'for logged-out user' do
      before do
        sign_out(user)
        sign_out(admin)
      end

      it 'redirects to login page' do
        send_request

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  shared_examples 'not available for non-admin users' do
    context 'for non-admin user' do
      before do
        sign_in(user)
      end

      it 'is not found' do
        send_request

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  shared_examples 'redirects to the search admin settings page' do
    it 'redirects to the search admin settings page' do
      send_request

      expect(response).to redirect_to(search_admin_application_settings_path)
    end
  end

  shared_examples 'checks semantic search availability and collection presence' do
    context 'when License is not available' do
      before do
        allow(::Ai::ActiveContext).to receive(:semantic_search_available?).and_return(false)
      end

      it_behaves_like 'redirects to the search admin settings page'
    end

    context 'when License has AI Features and Duo Features are enabled' do
      before do
        allow(::Ai::ActiveContext).to receive(:semantic_search_available?).and_return(true)
      end

      context 'when there is no active ActiveContext connection' do
        it_behaves_like 'redirects to the search admin settings page'

        context 'when there is an active ActiveContext connection' do
          let_it_be(:connection) { create(:ai_active_context_connection, :elasticsearch) }

          context 'when collection key is invalid' do
            let(:collection_key) { :dummy }

            it_behaves_like 'redirects to the search admin settings page'
          end

          context 'when collection record is missing' do
            let(:collection_key) { :code }

            it_behaves_like 'redirects to the search admin settings page'
          end
        end
      end
    end
  end

  shared_context 'when semantic search is available and collection exists' do
    before do
      allow(License).to receive(:ai_features_available?).and_return(true)
      allow(::Gitlab::CurrentSettings).to receive(:duo_features_enabled?).and_return(true)
    end

    let_it_be(:connection) { create(:ai_active_context_connection, :elasticsearch) }

    let(:collection_key) { :code }
    let_it_be(:collection_record) do
      create(
        :ai_active_context_collection,
        :code_collection,
        connection: connection
      )
    end
  end

  shared_examples 'does not show the model update form' do
    it 'displays the model details but does not show the update form' do
      collection_record.reload.update_metadata!(
        current_indexing_embedding_model: {
          model_type: :gitlab_managed,
          model_ref: 'text_embedding_005_vertex',
          field: 'test_embeddings_v1',
          dimensions: 768
        }
      )

      send_request

      expect(response.body).to have_css(
        "[data-testid='semantic-search-display-embedding-model-current']",
        text: /Gitlab-managed | text-embedding-005 - Vertex | 768/
      )

      expect(flash[:notice]).to eq(expected_flash_notice)
      expect(response.body).to have_css('[data-testid="semantic-search-embeddings"]')
      expect(response.body).not_to have_css('[data-testid="semantic-search-embeddings-form"]')
    end
  end

  shared_examples 'does not update the embedding model' do
    it 'does not update the embedding and shows a warning' do
      expect(::Ai::ActiveContext::EmbeddingModelActivationService).not_to receive(:new)

      send_request

      expect(flash[:alert]).to eq(expected_flash_alert)
      expect(response.body).to have_css('[data-testid="semantic-search-embeddings"]')
    end
  end

  def expect_inputs_disabled(response)
    expect(response.body).to have_css(
      "[data-testid='semantic-search-embeddings-model'][disabled='disabled']"
    )
    expect(response.body).to have_css(
      "[data-testid='semantic-search-embeddings-dimensions'][disabled='disabled']"
    )
    expect(response.body).to have_css(
      "[data-testid='semantic-search-embeddings-submit-button'][disabled='disabled']"
    )
  end

  describe 'GET #show' do
    subject(:send_request) do
      get admin_application_settings_semantic_search_embedding_path(collection_key.to_s)
    end

    let(:collection_key) { :code }

    it_behaves_like 'redirects logged-out users'
    it_behaves_like 'not available for non-admin users'

    context 'for admin user' do
      before do
        sign_in(admin)
      end

      it_behaves_like 'checks semantic search availability and collection presence'

      context 'when semantic search is available and collection exists' do
        include_context 'when semantic search is available and collection exists'

        context 'when instance does not support user model selection' do
          before do
            allow(::Ai::ActiveContext::Embeddings::ModelSelector).to receive(:user_can_select_model?).and_return(false)
          end

          it_behaves_like 'does not show the model update form' do
            let(:expected_flash_notice) { 'Model selection by user is not available in this Gitlab instance.' }
          end
        end

        context 'when user does not have permissions to update AI models' do
          before do
            allow(::Ai::ActiveContext::Embeddings::ModelSelector).to receive(:user_can_select_model?).and_return(true)
            allow(admin).to receive(:can?).with(:manage_instance_model_selection).and_return(false)
          end

          it_behaves_like 'does not show the model update form' do
            let(:expected_flash_notice) { 'You do not have sufficient permissions to update the model.' }
          end
        end

        context 'when user can update the embedding model' do
          before do
            allow(::Ai::ActiveContext::Embeddings::ModelSelector).to receive(:user_can_select_model?).and_return(true)
            allow(admin).to receive(:can?).with(:manage_instance_model_selection).and_return(true)
          end

          it 'allows setting the model without warnings' do
            send_request

            expect(response.body).to have_css(
              "[data-testid='semantic-search-embeddings-model']:not([disabled])"
            )
            expect(response.body).to have_css(
              "[data-testid='semantic-search-embeddings-dimensions']:not([disabled])"
            )
            expect(response.body).to have_css(
              "[data-testid='semantic-search-embeddings-submit-button']:not([disabled])",
              text: 'Set embeddings'
            )
          end

          context 'when collection record has current embedding model' do
            before do
              collection_record.reload.update_metadata!(
                current_indexing_embedding_model: {
                  model_type: current_model_type,
                  model_ref: 'text_embedding_005_vertex',
                  field: 'test_embeddings_v1',
                  dimensions: 768
                }
              )
            end

            let(:current_model_type) { :gitlab_managed }

            it 'displays the correct model information, allows update with warnings' do
              send_request

              expect(response.body).to have_css(
                "[data-testid='semantic-search-display-embedding-model-current']",
                text: /Gitlab-managed | text-embedding-005 - Vertex | 768/
              )

              expect(response.body).to have_css(
                "[data-testid='semantic-search-embeddings-model']:not([disabled]) " \
                  "option[selected][value='gitlab_managed__text_embedding_005_vertex']"
              )
              expect(response.body).to have_css(
                "[data-testid='semantic-search-embeddings-dimensions']:not([disabled]) " \
                  "option[selected][value='768']"
              )

              expect(response.body).to have_css(
                '[data-testid="semantic-search-embeddings-update-warning"]'
              )
              expect(response.body).to have_css(
                '[data-testid="semantic-search-embeddings-submit-button"]:not([disabled])',
                text: 'Update embeddings and start backfill process'
              )
            end

            context 'when current model_type is nil' do
              let(:current_model_type) { nil }

              it 'displays the correct model information without the model type' do
                send_request

                expect(response.body).not_to have_css(
                  "[data-testid='semantic-search-display-embedding-model-current']",
                  text: /Gitlab-managed/
                )
                expect(response.body).to have_css(
                  "[data-testid='semantic-search-display-embedding-model-current']",
                  text: /text-embedding-005 - Vertex | 768/
                )
              end
            end
          end

          context 'when collection record has next embedding model' do
            before do
              collection_record.reload.update_metadata!(
                next_indexing_embedding_model: {
                  model_type: :gitlab_managed,
                  model_ref: 'mock_embedding_001',
                  field: 'mock_embeddings_v1',
                  dimensions: 768
                }
              )
            end

            it 'shows the next model details, but disables inputs and submit button' do
              send_request

              expect(response.body).to have_css(
                "[data-testid='semantic-search-display-embedding-model-next']",
                text: /Gitlab-managed | text-embedding-005 - Vertex | 768/
              )

              expect_inputs_disabled(response)
            end
          end
        end
      end
    end
  end

  describe 'PUT #update' do
    subject(:send_request) do
      put(
        admin_application_settings_semantic_search_embedding_path(collection_key.to_s),
        params: update_params
      )
    end

    let(:collection_key) { :code }
    let(:update_params) { {} }

    it_behaves_like 'redirects logged-out users'
    it_behaves_like 'not available for non-admin users'

    context 'for admin user' do
      before do
        sign_in(admin)
      end

      it_behaves_like 'checks semantic search availability and collection presence'

      context 'when semantic search is available and collection exists' do
        include_context 'when semantic search is available and collection exists'

        before do
          allow(::Ai::ActiveContext::EmbeddingModelActivationService).to receive(:new).and_call_original

          # mock task chain creation
          task_service = instance_double(::Ai::ActiveContext::TaskService, create_chain: nil)
          allow(::Ai::ActiveContext::TaskService).to receive(:new).and_return(task_service)
        end

        context 'when instance does not support user model selection' do
          before do
            allow(::Ai::ActiveContext::Embeddings::ModelSelector).to receive(:user_can_select_model?).and_return(false)
          end

          it_behaves_like 'does not update the embedding model' do
            let(:expected_flash_alert) { 'User cannot update the model.' }
          end
        end

        context 'when user does not have permissions to update AI models' do
          before do
            allow(::Ai::ActiveContext::Embeddings::ModelSelector).to receive(:user_can_select_model?).and_return(true)
            allow(admin).to receive(:can?).with(:manage_instance_model_selection).and_return(false)
          end

          it_behaves_like 'does not update the embedding model' do
            let(:expected_flash_alert) { 'User cannot update the model.' }
          end
        end

        context 'when user can update the embedding model' do
          before do
            allow(::Ai::ActiveContext::Embeddings::ModelSelector).to receive(:user_can_select_model?).and_return(true)
            allow(admin).to receive(:can?).with(:manage_instance_model_selection).and_return(true)
          end

          context 'when embedding_model is not present' do
            let(:update_params) { { embedding_model: nil, embedding_dimensions: 768 } }

            it_behaves_like 'does not update the embedding model' do
              let(:expected_flash_alert) { 'Error: param is missing or the value is empty: embedding_model.' }
            end
          end

          context 'when embedding_dimensions is not present' do
            let(:update_params) { { embedding_model: 'gitlab_managed__test_model_1', embedding_dimensions: nil } }

            it_behaves_like 'does not update the embedding model' do
              let(:expected_flash_alert) { 'Error: param is missing or the value is empty: embedding_dimensions.' }
            end
          end

          context 'when required params are present' do
            let(:update_params) do
              {
                embedding_model: 'gitlab_managed__text_embedding_005_vertex',
                embedding_dimensions: 768
              }
            end

            it 'sets the embedding and disables inputs' do
              expect(::Ai::ActiveContext::EmbeddingModelActivationService).to receive(:new)

              send_request

              expect(flash[:notice]).to eq('Embedding model has been set.')

              expect(response.body).to have_css(
                "[data-testid='semantic-search-display-embedding-model-next']",
                text: /Gitlab-managed | text-embedding-005 - Vertex | 768/
              )

              expect_inputs_disabled(response)
            end

            context 'when collection record already has a current embedding model' do
              before do
                collection_record.reload.update_metadata!(
                  current_indexing_embedding_model: {
                    model_type: :gitlab_managed,
                    model_ref: 'embedding_model_001',
                    field: 'test_embeddings_v1',
                    dimensions: 768
                  }
                )
              end

              let(:update_params) do
                {
                  embedding_model: 'gitlab_managed__text_embedding_005_vertex',
                  embedding_dimensions: 768
                }
              end

              it 'updates the embedding and disables inputs' do
                expect(::Ai::ActiveContext::EmbeddingModelActivationService).to receive(:new)

                send_request

                expect(flash[:notice]).to eq('Embeddings updated and backfill started.')
                expect_inputs_disabled(response)
              end
            end

            context 'when EmbeddingModelActivationService throws an expected error' do
              it 'fails embedding update and shows the error message' do
                allow(::Ai::ActiveContext::EmbeddingModelActivationService).to receive(:new).and_raise(
                  ::Ai::ActiveContext::EmbeddingModelActivationService::Error,
                  "embedding model activation service failed"
                )

                send_request

                expect(flash[:alert]).to eq('Update failed: embedding model activation service failed.')
                expect(response.body).to have_css('[data-testid="semantic-search-embeddings"]')
              end
            end

            context 'when EmbeddingModelActivationService throws an unexpected error' do
              it 'fails embedding update and shows an unknown error warning' do
                allow(::Ai::ActiveContext::EmbeddingModelActivationService).to receive(:new).and_raise(
                  StandardError, "there is an error"
                )

                send_request

                expect(flash[:alert]).to eq('Update failed: unknown error.')
                expect(response.body).to have_css('[data-testid="semantic-search-embeddings"]')
              end
            end
          end
        end
      end
    end
  end
end
