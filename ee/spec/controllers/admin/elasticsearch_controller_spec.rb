# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::ElasticsearchController, feature_category: :global_search do
  let_it_be(:admin) { create(:admin) }
  let(:elasticsearch_settings_redirect) { search_admin_application_settings_path(anchor: 'js-elasticsearch-settings') }
  let(:reindexing_redirect) { search_admin_application_settings_path(anchor: 'js-elasticsearch-reindexing') }
  let(:semantic_search_redirect) { search_admin_application_settings_path(anchor: 'js-semantic-search-settings') }

  before do
    sign_in(admin)
  end

  describe 'POST #enqueue_index' do
    it 'starts indexing' do
      expect(::Search::Elastic::ReindexingService).to receive(:execute)

      post :enqueue_index

      expect(response).to redirect_to elasticsearch_settings_redirect
    end
  end

  describe 'POST #trigger_reindexing' do
    let(:params) do
      { search_elastic_reindexing_task: { elasticsearch_max_slices_running: 60, elasticsearch_slice_multiplier: 2 } }
    end

    it 'creates a reindexing task' do
      expect_next_instance_of(Search::Elastic::ReindexingTask) do |task|
        expect(task).to receive(:save).and_return(true)
      end

      post :trigger_reindexing, params: params

      expect(controller).to set_flash[:notice].to include('reindexing triggered')
      expect(response).to redirect_to reindexing_redirect
    end

    it 'does not create a reindexing task if there is another one' do
      allow(Search::Elastic::ReindexingTask).to receive(:current).and_return(build(:elastic_reindexing_task))

      post :trigger_reindexing, params: params

      expect(controller).to set_flash[:warning].to include('already in progress')
      expect(response).to redirect_to reindexing_redirect
    end

    it 'does not create a reindexing task if a required param is nil' do
      params = {
        search_elastic_reindexing_task: { elasticsearch_max_slices_running: nil, elasticsearch_slice_multiplier: 2 }
      }
      post :trigger_reindexing, params: params

      expect(controller).to set_flash[:alert].to include('Elasticsearch reindexing was not started')
      expect(response).to redirect_to reindexing_redirect
    end
  end

  describe 'POST #cancel_index_deletion' do
    let(:task) { create(:elastic_reindexing_task, state: :success, delete_original_index_at: Time.current) }

    it 'sets delete_original_index_at to nil' do
      post :cancel_index_deletion, params: { task_id: task.id }

      expect(task.reload.delete_original_index_at).to be_nil
      expect(controller).to set_flash[:notice].to include('deletion is canceled')
      expect(response).to redirect_to reindexing_redirect
    end
  end

  describe 'POST #use_advanced_search_cluster_for_semantic_search' do
    it 'connects to advanced search cluster for semantic search' do
      expect(Ai::ActiveContext::ConnectionService).to receive(:connect_to_advanced_search_cluster)

      post :use_advanced_search_cluster_for_semantic_search

      expect(controller).to set_flash[:notice].to eq('Successfully connected. Indexing will start soon.')
      expect(response).to redirect_to semantic_search_redirect
    end

    it 'handles connection errors gracefully' do
      allow(Ai::ActiveContext::ConnectionService).to receive(:connect_to_advanced_search_cluster)
        .and_raise(Ai::ActiveContext::ConnectionService::ConnectionError, 'Connection invalid')

      post :use_advanced_search_cluster_for_semantic_search

      expect(controller).to set_flash[:alert].to eq('Failed to connect: Connection invalid.')
      expect(response).to redirect_to search_vector_storage_admin_application_settings_path
    end
  end

  describe 'GET #vector_storage' do
    it 'renders successfully when an active connection exists' do
      create(:ai_active_context_connection)

      get :vector_storage

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'renders successfully when no active connection exists' do
      get :vector_storage

      expect(response).to have_gitlab_http_status(:ok)
    end

    context 'when using advanced search config' do
      it 'renders successfully' do
        create(:ai_active_context_connection, :elasticsearch, options: { 'use_advanced_search_config' => true })

        get :vector_storage

        expect(response).to have_gitlab_http_status(:ok)
      end
    end

    context 'when using custom connection' do
      it 'renders successfully' do
        create(:ai_active_context_connection, options: { 'url' => 'http://es.example.com', 'username' => 'user' })

        get :vector_storage

        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end

  describe 'POST #connect_custom_vector_storage' do
    let(:url) { 'http://es.example.com:9200' }
    let(:username) { 'user' }
    let(:password) { 'pass' }

    context 'when connection succeeds' do
      it 'calls the connection service and redirects with a notice' do
        expect(Ai::ActiveContext::ConnectionService).to receive(:connect_to_custom_elasticsearch_cluster)
          .with(url: url, username: username, password: password)

        post :connect_custom_vector_storage, params: { url: url, username: username, password: password }

        expect(response).to redirect_to semantic_search_redirect
        expect(controller).to set_flash[:notice].to eq('Successfully connected. Indexing will start soon.')
      end

      it 'passes nil for blank optional params' do
        expect(Ai::ActiveContext::ConnectionService).to receive(:connect_to_custom_elasticsearch_cluster)
          .with(url: url, username: nil, password: nil)

        post :connect_custom_vector_storage, params: { url: url, username: '', password: '' }

        expect(controller).to set_flash[:notice].to eq('Successfully connected. Indexing will start soon.')
        expect(response).to redirect_to semantic_search_redirect
      end
    end

    context 'when a ConnectionError is raised' do
      let(:error_message) { 'Connection refused' }

      before do
        allow(Ai::ActiveContext::ConnectionService).to receive(:connect_to_custom_elasticsearch_cluster)
          .and_raise(Ai::ActiveContext::ConnectionService::ConnectionError, error_message)
      end

      it 'sets an alert flash with the error message and returns 200' do
        post :connect_custom_vector_storage, params: { url: url }

        expect(controller).to set_flash[:alert].to eq("Failed to connect: #{error_message}.")
        expect(response).to have_gitlab_http_status(:ok)
      end
    end

    context 'when an ActiveRecord::RecordInvalid error is raised' do
      before do
        allow(Ai::ActiveContext::ConnectionService).to receive(:connect_to_custom_elasticsearch_cluster)
          .and_raise(ActiveRecord::RecordInvalid.new(
            build(:ai_active_context_connection, :elasticsearch, options: { url: '' }).tap(&:valid?)
          ))
      end

      it 'sets an alert flash with the full sentence error and returns 200' do
        post :connect_custom_vector_storage, params: { url: '' }

        expect(controller).to set_flash[:alert].to eq("Failed to connect: URL can't be blank.")
        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end

  describe 'POST #disable_semantic_search' do
    it 'disables semantic search' do
      expect(Ai::ActiveContext::ConnectionService).to receive(:disable_connection)

      post :disable_semantic_search

      expect(controller).to set_flash[:notice].to include('Semantic search will be disabled soon')
      expect(response).to redirect_to semantic_search_redirect
    end
  end

  describe 'POST #retry_migration' do
    let(:migration) { Elastic::DataMigrationService.migrations.last }

    it 'deletes the migration record and drops the halted cache' do
      allow(Elastic::MigrationRecord).to receive(:new).and_call_original
      allow(Elastic::MigrationRecord).to receive(:new)
        .with(version: migration.version, name: migration.name, filename: migration.filename).and_return(migration)
      allow(Elastic::DataMigrationService).to receive(:migration_halted?).and_return(false)
      allow(Elastic::DataMigrationService).to receive(:migration_halted?).with(migration).and_return(true, false)
      expect(Elastic::DataMigrationService.halted_migrations?).to be_truthy

      post :retry_migration, params: { version: migration.version }

      expect(Elastic::DataMigrationService.halted_migrations?).to be_falsey
      expect(controller).to set_flash[:notice].to include('Migration has been scheduled to be retried')
      expect(response).to redirect_to elasticsearch_settings_redirect
    end
  end
end
