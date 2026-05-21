# frozen_string_literal: true

module Admin
  module SemanticSearchEmbeddingsHelper # rubocop: disable Search/NamespacedClass -- this is for semantic search admin settings
    def collection_name(collection_key)
      collection_key.to_s.humanize
    end

    def embedding_model_display_name(model)
      [
        model_type_display(model[:model_type]),
        model_name(model),
        model[:dimensions]
      ].compact.join(" | ")
    end

    def model_type_display(model_type)
      return unless model_type

      model_type.to_s.tr('_', '-').capitalize
    end

    def model_name(model)
      # Since we are only supporting Gitlab-managed models for now,
      # we can get all model names from the ::Ai::ActiveContext::Embedding::MODELS_LOOKUP
      ::Ai::ActiveContext::Embedding::MODELS_LOOKUP[model[:model_ref]]&.fetch(:model_name)
    end

    def embedding_models_grouped_options(current_model)
      grouped_options = [
        [
          model_type_display(::Ai::ActiveContext::Embedding::MODEL_TYPE_GITLAB_MANAGED),
          gitlab_managed_model_options
        ]
      ]

      unless current_model
        grouped_options.unshift(
          [
            "No model selected",
            [["--", nil]]
          ]
        )
      end

      grouped_options
    end

    def gitlab_managed_model_options
      ::Ai::ActiveContext::Embedding::MODELS_LOOKUP.map do |k, v|
        [
          v[:model_name],
          embedding_model_key({
            model_type: ::Ai::ActiveContext::Embedding::MODEL_TYPE_GITLAB_MANAGED,
            model_ref: k
          })
        ]
      end
    end

    def embedding_dimensions_options(current_model)
      options = ::Ai::ActiveContext::Embedding::EMBEDDING_DIMENSIONS.map { |d| [d, d] }

      options.unshift(["--", nil]) unless current_model

      options
    end

    def embedding_model_key(model)
      return if model.blank?

      "#{model[:model_type]}__#{model[:model_ref]}"
    end

    def embedding_model_dimensions(model)
      return if model.blank?

      model[:dimensions]
    end
  end
end
