# frozen_string_literal: true

module Search
  module Admin
    class VectorStorageController < ::Admin::ApplicationController
      include Gitlab::Utils::StrongMemoize

      feature_category :global_search
      urgency :low

      before_action :set_vector_storage, only: [:show, :connect_custom_vector_storage]

      def show; end

      # POST
      # Connect to Advanced Search cluster for semantic search
      def use_advanced_search_cluster_for_semantic_search
        ::Ai::ActiveContext::ConnectionService.connect_to_advanced_search_cluster

        flash[:notice] = s_('SemanticSearch|Successfully connected. Indexing will start soon.')

        redirect_to redirect_path(anchor: 'js-semantic-search-settings')
      rescue ::Ai::ActiveContext::ConnectionService::ConnectionError => e
        flash[:alert] = format(s_('SemanticSearch|Failed to connect: %{error}.'), error: e.message)

        redirect_to search_vector_storage_admin_application_settings_path
      end

      # POST
      # Connect to a custom Elasticsearch cluster for semantic search
      def connect_custom_vector_storage
        ::Ai::ActiveContext::ConnectionService.connect_to_custom_elasticsearch_cluster(
          url: vector_storage_params[:url].presence,
          username: vector_storage_params[:username].presence,
          password: vector_storage_params[:password].presence
        )

        flash[:notice] = s_('SemanticSearch|Successfully connected. Indexing will start soon.')

        redirect_to redirect_path(anchor: 'js-semantic-search-settings')
      rescue ::Ai::ActiveContext::ConnectionService::ConnectionError => e
        flash.now[:alert] = format(s_('SemanticSearch|Failed to connect: %{error}.'), error: e.message)
        render :show
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:alert] =
          format(s_('SemanticSearch|Failed to connect: %{error}.'), error: e.record.errors.full_messages.to_sentence)
        render :show
      end

      # POST
      # Disable semantic search
      def disable_semantic_search
        ::Ai::ActiveContext::ConnectionService.disable_connection

        flash[:notice] = s_('SemanticSearch|Semantic search will be disabled soon.')

        redirect_to redirect_path(anchor: 'js-semantic-search-settings')
      end

      private

      def redirect_path(anchor: 'js-semantic-search-settings')
        search_admin_application_settings_path(anchor: anchor)
      end

      def set_vector_storage
        @connection = connection
        @using_advanced_search = use_advanced_search_config
        @custom_active = connection.present? && !use_advanced_search_config
        @inputs_disabled = use_advanced_search_config
        @custom_options = custom_options
      end

      def connection
        ::Ai::ActiveContext::Connection.active
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
  end
end
