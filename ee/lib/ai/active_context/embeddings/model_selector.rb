# frozen_string_literal: true

module Ai
  module ActiveContext
    module Embeddings
      class ModelSelector
        MissingModelDefinition = Class.new(StandardError)
        UnexpectedModelConfiguration = Class.new(StandardError)
        UnsupportedModelConfiguration = Class.new(StandardError)

        # We arrived at `40` for the initial batch size calculation:
        #   https://gitlab.com/gitlab-org/gitlab/-/issues/551002#note_2595329124
        # This is still resulting in a non-trivial volume of token limit exceeded errors,
        #   so we pre-emptively reduce to `30`:
        #   https://gitlab.com/groups/gitlab-org/-/epics/20977#note_3096296135
        TEXT_EMBEDDING_VERTEX_BATCH_SIZE = 30

        # The key for this lookup corresponds to the `model_ref` in the collection record metadata.
        # The format has to follow the convention in AIGW's `ai_gateway/model_selection/models.yml`,
        #   which is the global registry for GitLab-managed models.
        # Once we implement the specialized `/embeddings` endpoint in AIGW,
        #   we will add embedding model definitions to the `ai_gateway/model_selection/models.yml`.
        #   For GitLab-managed models, the `/embeddings` endpoint will refer to this yaml file
        #   to determine the model and provider given the `model_ref`.
        # The `model` value in this lookup is needed because we are still using the Vertex Proxy API.
        # Related work items:
        #   - https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/work_items/1866
        #   - https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/work_items/1879
        MODELS_LOOKUP = {
          'text_embedding_005_vertex' => {
            model: 'text-embedding-005',
            batch_size: TEXT_EMBEDDING_VERTEX_BATCH_SIZE
          }
        }.freeze

        MODEL_TYPE_GITLAB_MANAGED = :gitlab_managed
        SELF_HOSTED_MODEL_TYPES = [
          MODEL_TYPE_GITLAB_MANAGED
        ].freeze

        def self.use_gitlab_selected_model?
          ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions) ||
            ::Gitlab::CurrentSettings.gitlab_dedicated_instance? ||
            !::Gitlab::AiGateway.has_self_hosted_ai_gateway?
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
          unless SELF_HOSTED_MODEL_TYPES.include?(model_type)
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
            model_name: gitlab_model_definition[:model],
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

        def embedding_field
          @embedding_field ||= model_metadata[:field]
        end

        def gitlab_model_definition
          @gitlab_model_definition ||= MODELS_LOOKUP[model_ref]
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
