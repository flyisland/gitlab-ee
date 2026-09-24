# frozen_string_literal: true

module Gitlab
  module Llm
    module ChatGlm
      module ResponseModifiers
        class ChatV3 < ::Gitlab::Llm::BaseResponseModifier
          def response_body
            @response_body ||= if ai_response[:success]
                                 content = ai_response&.dig(:data, :choices, 0, :content).to_s.strip
                                 # remove head & tail quote, replace \\n with \n from chatglm
                                 content = content[0] == '"' && content[-1] == '"' ? content[1..-2] : content
                                 content.gsub("\\n", "\n")
                               end
          end

          def errors
            @errors ||= ai_response&.dig(:success) == true ? [] : [ai_response&.dig(:msg)].compact
          end
        end
      end
    end
  end
end
