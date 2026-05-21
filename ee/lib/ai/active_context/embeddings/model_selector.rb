# frozen_string_literal: true

module Ai
  module ActiveContext
    module Embeddings
      class ModelSelector
        MissingModelDefinition = Class.new(StandardError)
        UnexpectedModelConfiguration = Class.new(StandardError)
        UnsupportedModelConfiguration = Class.new(StandardError)

        def self.use_gitlab_selected_model?
          ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions) ||
            ::Gitlab::CurrentSettings.gitlab_dedicated_instance? ||
            !::Gitlab::AiGateway.has_self_hosted_ai_gateway?
        end

        def self.user_can_select_model?
          !use_gitlab_selected_model? && Feature.enabled?(:semantic_search_user_model_selection, :instance)
        end

        def self.for(model_metadata, search: false)
          new(model_metadata, search: search).execute
        end

        def initialize(model_metadata, search: false)
          @model_metadata = model_metadata
          @search = search
        end

        def execute
          return if model_metadata.nil?

          validate_model_ref_and_field!
          validate_model_type!

          return gitlab_managed_model if self.class.use_gitlab_selected_model?

          user_selected_model
        end

        private

        attr_reader :model_metadata, :search

        def user_selected_model
          unless ::Ai::ActiveContext::Embedding::MODEL_TYPES.include?(model_type)
            raise UnsupportedModelConfiguration, "Unsupported `model_type` value: #{model_type}"
          end

          gitlab_managed_model(use_cloud_aigw: true)
        end

        def gitlab_managed_model(use_cloud_aigw: false)
          validate_gitlab_model_definition!

          model_definition = ::Gitlab::Llm::Embeddings::ModelDefinition.for_gitlab_provided_code_embeddings(
            identifier: model_ref,
            use_cloud_aigw: use_cloud_aigw
          )

          ::ActiveContext::EmbeddingModel.new(
            model_key: model_key(::Ai::ActiveContext::Embedding::MODEL_TYPE_GITLAB_MANAGED),
            field: embedding_field,
            llm_class: ::Gitlab::Llm::Embeddings::CodeEmbeddings,
            llm_params: {
              model_definition: model_definition,
              batch_size: gitlab_model_definition[:batch_size],
              search: search
            }
          )
        end

        def model_ref
          @model_ref ||= model_metadata[:model_ref]
        end

        def model_type
          @model_type ||= model_metadata[:model_type]&.to_sym
        end

        def model_key(type)
          "#{type}__#{model_ref}"
        end

        def embedding_field
          @embedding_field ||= model_metadata[:field]
        end

        def gitlab_model_definition
          @gitlab_model_definition ||= ::Ai::ActiveContext::Embedding::MODELS_LOOKUP[model_ref]
        end

        def validate_model_ref_and_field!
          return if model_ref.present? && embedding_field.present?

          raise UnexpectedModelConfiguration, "`model_metadata` must have a `model_ref` and `field`"
        end

        def validate_model_type!
          return if self.class.use_gitlab_selected_model? || model_type.present?

          raise(
            UnexpectedModelConfiguration,
            "`model_metadata` must have a `model_type` if Duo Self-Hosted is configured"
          )
        end

        def validate_gitlab_model_definition!
          return if gitlab_model_definition.present?

          raise MissingModelDefinition, "Missing definitions for Gitlab-managed model: #{model_ref}"
        end
      end
    end
  end
end
