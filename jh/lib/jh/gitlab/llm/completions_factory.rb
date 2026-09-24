# frozen_string_literal: true

module JH
  module Gitlab
    module Llm
      module CompletionsFactory
        extend ActiveSupport::Concern

        # TODO:
        # service_class should be general and move out of specific ai module
        # prompt_class should be couple with specific ai module
        EXTENDED_COMPLETIONS = {
          chat_glm: {
            explain_code: {
              service_class: ::Gitlab::Llm::ChatGlm::Completions::ExplainCode,
              prompt_class: ::Gitlab::Llm::ChatGlm::Templates::ExplainCode
            }
          },
          mini_max: {
            explain_code: {
              service_class: ::Gitlab::Llm::MiniMax::Completions::ExplainCode,
              prompt_class: ::Gitlab::Llm::MiniMax::Templates::ExplainCode
            }
          }
        }.freeze

        class_methods do
          def completions
            jh_completions = EXTENDED_COMPLETIONS.fetch(::Gitlab::Llm::ClientFactory.ai_provider, {})
            ::Gitlab::Llm::Utils::AiFeaturesCatalogue::LIST.merge(jh_completions)
          end
        end
      end
    end
  end
end
