# frozen_string_literal: true

module Gitlab
  module Llm
    module MiniMax
      module ResponseModifiers
        class Chat < ::Gitlab::Llm::BaseResponseModifier
          def response_body
            @response_body ||= ai_response&.dig(:reply).to_s.strip
          end

          def errors
            @errors ||= begin
              error_message = ai_response&.dig(:base_resp, :status_msg)
              error_message.present? ? [error_message] : []
            end
          end
        end
      end
    end
  end
end
