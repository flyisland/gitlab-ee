# frozen_string_literal: true

module Gitlab
  module Llm
    module MiniMax
      module Templates
        class ExplainCode
          TEMPERATURE = 0.3

          def self.get_options(messages)
            new_messages = messages.filter_map do |info|
              case info['role']
              when 'system', 'assistant'
                { sender_type: "BOT", sender_name: "JIHU_BOT", text: info['content'] }
              when 'user'
                { sender_type: "USER", sender_name: "user", text: info['content'] }
              end
            end

            {
              messages: new_messages,
              temperature: TEMPERATURE,
              # we can set different bot_settings depend on ai features
              bot_setting: [
                {
                  bot_name: "JIHU_BOT",
                  content: "你是一个软件研发专家，请帮助我解释代码的相关问题"
                }
              ]
            }
          end
        end
      end
    end
  end
end
