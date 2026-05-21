# frozen_string_literal: true

module Ai
  module ActiveContext
    module Embedding
      MODEL_TYPE_GITLAB_MANAGED = :gitlab_managed

      # This should be kept in sync with `ai_active_context_embedding_metadata.model_type` enum
      # in ee/app/validators/json_schemas/ai_active_context_embedding_metadata.json
      MODEL_TYPES = [
        MODEL_TYPE_GITLAB_MANAGED
      ].freeze

      # This should be kept in sync with `ai_active_context_embedding_metadata.dimensions` enum
      # in ee/app/validators/json_schemas/ai_active_context_embedding_metadata.json
      EMBEDDING_DIMENSIONS = [768].freeze

      # We arrived at `40` for the initial batch size calculation:
      #   https://gitlab.com/gitlab-org/gitlab/-/issues/551002#note_2595329124
      # This is still resulting in a non-trivial volume of token limit exceeded errors,
      #   so we pre-emptively reduce to `30`:
      #   https://gitlab.com/groups/gitlab-org/-/epics/20977#note_3096296135
      TEXT_EMBEDDING_VERTEX_BATCH_SIZE = 30

      # This lookup is only used for Gitlab-managed models.
      # The hash keys should correspond to the models defined in AIGW's `ai_gateway/model_selection/models.yml`.
      # In turn, the collection record `metadata[:model_ref]` should correspond to a key in this lookup.
      MODELS_LOOKUP = {
        'text_embedding_005_vertex' => {
          model_name: 'text-embedding-005 - Vertex',
          batch_size: TEXT_EMBEDDING_VERTEX_BATCH_SIZE
        }
      }.freeze

      def self.valid_model_ref?(model_ref)
        MODELS_LOOKUP.key?(model_ref)
      end
    end
  end
end
