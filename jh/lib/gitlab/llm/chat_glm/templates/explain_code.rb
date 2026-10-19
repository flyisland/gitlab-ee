# frozen_string_literal: true

module Gitlab
  module Llm
    module ChatGlm
      module Templates
        class ExplainCode
          TEMPERATURE = 0.3

          def self.get_options(messages)
            {
              content: messages.select { |info| info['role'] != 'system' },
              temperature: TEMPERATURE
            }
          end
        end
      end
    end
  end
end
