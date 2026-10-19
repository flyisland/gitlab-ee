# frozen_string_literal: true

module Gitlab
  module Llm
    module ChatGlm
      module Completions
        class ExplainCode < Gitlab::Llm::Completions::Base
          def execute
            client_options = ai_prompt_class.get_options(options[:messages])

            ai_response = ::Gitlab::Llm::ClientFactory.client.new(user).chat_v3(content: options[:content],
**client_options)
            response_modifier = ::Gitlab::Llm::ChatGlm::ResponseModifiers::ChatV3.new(ai_response)

            ::Gitlab::Llm::GraphqlSubscriptionResponseService
              .new(user, project, response_modifier, options: response_options)
              .execute
          end

          private

          def project
            resource
          end
        end
      end
    end
  end
end
