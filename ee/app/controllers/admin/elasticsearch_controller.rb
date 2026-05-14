# frozen_string_literal: true

class Admin::ElasticsearchController < Admin::ApplicationController
  include Gitlab::Utils::StrongMemoize

  feature_category :global_search
  urgency :low

  before_action :set_vector_storage, only: [:vector_storage, :connect_custom_vector_storage]

  # POST
  # Scheduling indexing jobs
  def enqueue_index
    ::Search::Elastic::ReindexingService.execute

    flash[:notice] =
      _('Advanced search indexing in progress. It might take a few minutes to create indices and initiate indexing. ' \
        'Please use gitlab:elastic:info rake task to check progress.')

    redirect_to redirect_path
  end

  # POST
  # Trigger reindexing task
  def trigger_reindexing
    if Search::Elastic::ReindexingTask.running?
      flash[:warning] = _('Elasticsearch reindexing is already in progress')
    else
      @elasticsearch_reindexing_task = Search::Elastic::ReindexingTask.new(trigger_reindexing_params)
      if @elasticsearch_reindexing_task.save
        flash[:notice] = _('Elasticsearch reindexing triggered')
      else
        errors = @elasticsearch_reindexing_task.errors.full_messages.join(', ')
        flash[:alert] = format(_("Elasticsearch reindexing was not started: %{errors}"), errors: errors)
      end
    end

    redirect_to redirect_path(anchor: 'js-elasticsearch-reindexing')
  end

  # POST
  # Cancel index deletion after a successful reindexing operation
  def cancel_index_deletion
    task = Search::Elastic::ReindexingTask.find(cancel_index_deletion_params[:task_id])
    task.update!(delete_original_index_at: nil)

    flash[:notice] = _('Index deletion is canceled')

    redirect_to redirect_path(anchor: 'js-elasticsearch-reindexing')
  end

  # POST
  # Connect to Advanced Search cluster for semantic search
  def use_advanced_search_cluster_for_semantic_search
    Ai::ActiveContext::ConnectionService.connect_to_advanced_search_cluster

    flash[:notice] = s_('SemanticSearch|Successfully connected. Indexing will start soon.')

    redirect_to redirect_path(anchor: 'js-semantic-search-settings')
  rescue Ai::ActiveContext::ConnectionService::ConnectionError => e
    flash[:alert] = format(s_('SemanticSearch|Failed to connect: %{error}.'), error: e.message)

    redirect_to search_vector_storage_admin_application_settings_path
  end

  def vector_storage; end

  # POST
  # Connect to a custom Elasticsearch cluster for semantic search
  def connect_custom_vector_storage
    Ai::ActiveContext::ConnectionService.connect_to_custom_elasticsearch_cluster(
      url: vector_storage_params[:url].presence,
      username: vector_storage_params[:username].presence,
      password: vector_storage_params[:password].presence
    )

    flash[:notice] = s_('SemanticSearch|Successfully connected. Indexing will start soon.')

    redirect_to redirect_path(anchor: 'js-semantic-search-settings')
  rescue Ai::ActiveContext::ConnectionService::ConnectionError => e
    flash[:alert] = format(s_('SemanticSearch|Failed to connect: %{error}.'), error: e.message)
    render :vector_storage
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] =
      format(s_('SemanticSearch|Failed to connect: %{error}.'), error: e.record.errors.full_messages.to_sentence)
    render :vector_storage
  end

  # POST
  # Disable semantic search
  def disable_semantic_search
    Ai::ActiveContext::ConnectionService.disable_connection

    flash[:notice] = s_('SemanticSearch|Semantic search will be disabled soon.')

    redirect_to redirect_path(anchor: 'js-semantic-search-settings')
  end

  # POST
  # Retry a halted migration
  def retry_migration
    migration = Elastic::DataMigrationService[retry_migration_params[:version].to_i]

    Gitlab::Elastic::Helper.default.delete_migration_record(migration)
    Elastic::DataMigrationService.drop_migration_halted_cache!(migration)

    flash[:notice] = _('Migration has been scheduled to be retried')

    redirect_to redirect_path
  end

  private

  def redirect_path(anchor: 'js-elasticsearch-settings')
    search_admin_application_settings_path(anchor: anchor)
  end

  def cancel_index_deletion_params
    params.permit(:task_id)
  end

  def retry_migration_params
    params.permit(:version)
  end

  def trigger_reindexing_params
    permitted_params = params.require(:search_elastic_reindexing_task).permit(:elasticsearch_max_slices_running,
      :elasticsearch_slice_multiplier)
    trigger_reindexing_params = {}
    if permitted_params.has_key?(:elasticsearch_max_slices_running)
      trigger_reindexing_params[:max_slices_running] =
        permitted_params[:elasticsearch_max_slices_running]
    end

    if permitted_params.has_key?(:elasticsearch_slice_multiplier)
      trigger_reindexing_params[:slice_multiplier] =
        permitted_params[:elasticsearch_slice_multiplier]
    end

    trigger_reindexing_params
  end

  def set_vector_storage
    @connection = connection
    @using_advanced_search = use_advanced_search_config
    @custom_active = connection.present? && !use_advanced_search_config
    @inputs_disabled = use_advanced_search_config
    @custom_options = custom_options
  end

  def connection
    Ai::ActiveContext::Connection.active
  end
  strong_memoize_attr :connection

  def use_advanced_search_config
    connection&.use_advanced_search_config?
  end
  strong_memoize_attr :use_advanced_search_config

  def custom_options
    if vector_storage_params[:url].present?
      vector_storage_params
    elsif !use_advanced_search_config
      connection&.stored_options || {}
    else
      {}
    end
  end

  def vector_storage_params
    params.permit(:url, :username, :password)
  end
  strong_memoize_attr :vector_storage_params
end
