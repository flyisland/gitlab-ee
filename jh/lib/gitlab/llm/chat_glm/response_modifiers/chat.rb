# frozen_string_literal: true

module Gitlab
  module Llm
    module ChatGlm
      module ResponseModifiers
        class Chat < ::Gitlab::Llm::BaseResponseModifier
          def response_body
            ai_response&.dig(:data, :outputText).to_s.strip if ai_response&.dig(:success)
          end

          def errors
            return [] if ai_response[:success]

            [ai_response[:msg]].compact
          end
        end
      end
    end
  end
end
