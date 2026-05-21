# frozen_string_literal: true

module Admin
  module ApplicationSettings
    class SemanticSearchEmbeddingsController < Admin::ApplicationController # rubocop: disable Search/NamespacedClass -- this is for semantic search admin settings
      include Gitlab::Loggable

      feature_category :global_search
      urgency :low

      before_action :redirect_if_semantic_search_unavailable
      before_action :collection_key, only: [:show, :update]
      before_action :redirect_if_collection_unavailable, only: [:show, :update]
      before_action :user_can_update_model, only: [:show, :update]
      before_action :embedding_models, only: [:show, :update]
      before_action :check_inputs_disablement, only: [:show, :update]

      COLLECTION_CLASS_LOOKUP = {
        code: ::Ai::ActiveContext::Collections::Code
      }.freeze

      def show
        unless @instance_allows_user_model_selection
          flash.now[:notice] = "Model selection by user is not available in this Gitlab instance."
          return
        end

        unless @user_has_update_model_permissions
          flash.now[:notice] = "You do not have sufficient permissions to update the model."
          return
        end

        return unless @next_model

        flash.now[:notice] = "You cannot update the model at this time. " \
          "There is already a next embedding model."
      end

      def update
        update_embedding_model if pre_update_checks

        render :show
      end

      private

      def collection_key
        @collection_key = params.require(:id).to_sym
      end

      def collection_class
        COLLECTION_CLASS_LOOKUP[@collection_key]
      end

      def redirect_if_semantic_search_unavailable
        if ::Ai::ActiveContext.semantic_search_available? &&
            ::ActiveContext.adapter&.connection.present?
          return
        end

        redirect_to search_admin_application_settings_path
      end

      def redirect_if_collection_unavailable
        return if collection_class&.collection_record.present?

        redirect_to search_admin_application_settings_path
      end

      def user_can_update_model
        @instance_allows_user_model_selection = ::Ai::ActiveContext::Embeddings::ModelSelector.user_can_select_model?
        @user_has_update_model_permissions = current_user.can?(:manage_instance_model_selection) # rubocop: disable Gitlab/Authz/PermissionCheck -- there is no specific permission

        @user_can_update_model = @instance_allows_user_model_selection && @user_has_update_model_permissions
      end

      def embedding_models
        collection_record = collection_class.collection_record.reset
        @current_model = collection_record.current_indexing_embedding_model
        @next_model = collection_record.next_indexing_embedding_model
      end

      def check_inputs_disablement
        @disable_inputs = !@user_can_update_model || !!@next_model
      end

      def pre_update_checks
        return unless validate_user_can_update
        return unless require_update_params

        true
      end

      def validate_user_can_update
        return true if @user_can_update_model

        flash.now[:alert] = 'User cannot update the model.'
        false
      end

      def require_update_params
        model_details = params.require(:embedding_model).split("__")
        embedding_dimensions = params.require(:embedding_dimensions)

        @update_params = {
          model_type: model_details.first.to_sym,
          model_ref: model_details.second.to_s,
          dimensions: embedding_dimensions.to_i
        }

        true
      rescue ActionController::ParameterMissing => e
        flash.now[:alert] = "Error: #{e.message}."
        false
      end

      def post_update_reloads
        embedding_models
        check_inputs_disablement
      end

      def update_embedding_model
        ::Ai::ActiveContext::EmbeddingModelActivationService.new(
          collection_class: collection_class,
          **@update_params
        ).execute!

        post_update_reloads
        flash_update_successful
      rescue StandardError => e
        logger.error(
          build_structured_payload(
            collection: @collection_key,
            error_class: e.class.name,
            message: e.message,
            **@update_params
          )
        )

        flash_update_failed(e)
      end

      def flash_update_successful
        return flash.now[:notice] = 'Embedding model has been set.' unless @current_model

        flash.now[:notice] = 'Embeddings updated and backfill started.'
      end

      def flash_update_failed(error)
        error_detail = error.message if error.is_a?(::Ai::ActiveContext::EmbeddingModelActivationService::Error)
        error_detail ||= 'unknown error'

        flash.now[:alert] = "Update failed: #{error_detail}."
      end

      def logger
        @logger ||= ::ActiveContext::Config.logger
      end
    end
  end
end
