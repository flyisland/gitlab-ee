# frozen_string_literal: true

module Gitlab
  module Llm
    module Embeddings
      class ModelDefinition
        attr_reader :feature_name, :unit_primitive, :provider, :identifier, :use_cloud_aigw

        UNIT_PRIMITIVE_GENERATE_EMBEDDINGS_CODEBASE = 'generate_embeddings_codebase'

        FEATURE_CODE_EMBEDDINGS = :embeddings_code

        PROVIDER_GITLAB = "gitlab"

        TOKEN_LIMIT_EXCEEDED_PATTERNS = {
          'text_embedding_005_vertex' => /the input token count is \d+ but the model supports up to \d+/
        }.freeze

        def self.for_gitlab_provided_code_embeddings(identifier: nil, use_cloud_aigw: false)
          new(
            feature_name: FEATURE_CODE_EMBEDDINGS,
            unit_primitive: UNIT_PRIMITIVE_GENERATE_EMBEDDINGS_CODEBASE,
            provider: PROVIDER_GITLAB,
            identifier: identifier,
            use_cloud_aigw: use_cloud_aigw
          )
        end

        def initialize(feature_name:, unit_primitive:, provider:, identifier: nil, use_cloud_aigw: false)
          @feature_name = feature_name
          @unit_primitive = unit_primitive
          @provider = provider
          @identifier = identifier
          @use_cloud_aigw = use_cloud_aigw
        end

        def aigw_base_url
          @aigw_base_url ||= use_cloud_aigw ? ::Gitlab::AiGateway.cloud_connector_url : ::Gitlab::AiGateway.url
        end

        def model_params
          {
            provider: provider,
            identifier: identifier
          }
        end

        def catch_token_limit_exceeded_errors?
          TOKEN_LIMIT_EXCEEDED_PATTERNS.key?(identifier)
        end

        def token_limit_exceeded_message_pattern
          TOKEN_LIMIT_EXCEEDED_PATTERNS[identifier]
        end

        def gitlab_managed?
          provider == PROVIDER_GITLAB
        end
      end
    end
  end
end
