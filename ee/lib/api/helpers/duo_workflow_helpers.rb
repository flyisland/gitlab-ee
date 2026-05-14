# frozen_string_literal: true

module API
  module Helpers
    module DuoWorkflowHelpers
      def push_ai_gateway_headers(scope: nil)
        push_feature_flags

        governing_namespace_id = current_user.governing_namespace(scope)&.id

        Gitlab::AiGateway.public_headers(
          user: current_user,
          ai_feature_name: :duo_workflow,
          unit_primitive_name: :duo_workflow_execute_workflow,
          governing_namespace_id: governing_namespace_id).each do |name, value|
          header(name, value)
        end
      end

      def push_feature_flags
        Gitlab::AiGateway.push_feature_flag(:expanded_ai_logging, current_user)
        Gitlab::AiGateway.push_feature_flag(:duo_agentic_chat_openai_gpt_5, current_user)
        Gitlab::AiGateway.push_feature_flag(:duo_workflow_stream_during_tool_call_generation, current_user)
        Gitlab::AiGateway.push_feature_flag(:duo_workflow_compress_checkpoint, current_user)
        Gitlab::AiGateway.push_feature_flag(:use_generic_gitlab_api_tools, current_user)
        Gitlab::AiGateway.push_feature_flag(:ai_prompt_scanning, current_user)
        Gitlab::AiGateway.push_feature_flag(:dap_web_search, current_user)
        Gitlab::AiGateway.push_feature_flag(:ai_context_compaction, current_user)
      end
    end
  end
end
