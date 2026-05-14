# frozen_string_literal: true

module Gitlab
  module Llm
    module AiGateway
      module Completions
        class ClassifyCodeReviewMentionIntent < Base
          extend ::Gitlab::Utils::Override

          # Intent values returned by the AI Gateway classifier prompt defined in:
          # https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/blob/main/ai_gateway/prompts/definitions/classify_code_review_mention_intent/system/1.0.0.jinja
          INTENT_CODE_REVIEW = 'code_review_request'
          INTENT_WRITE_ACTIONS = 'write_actions'
          INTENT_AGENTIC_CHAT = 'agentic_chat'

          override :inputs
          def inputs
            { message: options[:message] }
          end

          private

          # The AI Gateway prompt uses unit_primitive: duo_agent_platform, not a dedicated
          # unit primitive, so we must override the default (which would use ai_action as the UP).
          override :unit_primitive_name
          def unit_primitive_name
            :duo_agent_platform
          end
        end
      end
    end
  end
end
