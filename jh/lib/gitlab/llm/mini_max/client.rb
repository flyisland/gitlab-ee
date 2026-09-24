# frozen_string_literal: true

module Gitlab
  module Llm
    module MiniMax
      class Client
        HOST = 'https://api.minimax.chat'
        ENGINES_PATH = '/v1/text/chatcompletion_pro'

        DEFAULT_TEMPERATURE = 0.6

        DEFAULT_OPTIONS = {
          temperature: DEFAULT_TEMPERATURE,
          messages: [],
          model: 'abab5.5-chat',
          bot_setting: [
            {
              bot_name: "JIHU_BOT",
              content: "你是一个软件研发专家，可以回答任何软件研发过程中的问题"
            }
          ],
          reply_constraints: {
            sender_type: "BOT",
            sender_name: "JIHU_BOT"
          }
        }.freeze

        Error = Class.new(StandardError)
        attr_reader :logger

        def initialize(user)
          @user = user
          @group_id = ENV['CHAT_MINIMAX_GROUP_ID']
          @api_key = ENV['CHAT_MINIMAX_API_KEY']

          raise Error, 'invalid configuration' unless @group_id.present? && @api_key.present?

          @logger = Gitlab::Llm::Logger.build
        end

        # try to rename content to messages in options, support both messages & content params
        def chat(options)
          content = options.delete(:content)
          options[:messages] = content if content.present?

          body = DEFAULT_OPTIONS.merge(options)
          logger.debug(message: "Performing request to MINIMAX: #{body}", klass: to_s, event_name: 'minimax',
            ai_component: 'abstraction_layer')

          post_response = ::Gitlab::HTTP.post(chat_minimax_url, body: body.to_json, headers: headers)
          response = options[:parsed_response] ? post_response.parsed_response : post_response.body

          logger.debug(message: "Received response from MINIMAX: #{response}", klass: to_s, event_name: 'minimax',
            ai_component: 'abstraction_layer')

          response
        rescue *Gitlab::HTTP::HTTP_ERRORS => e
          raise Error, "request chat failed: #{e.message}"
        end

        private

        def chat_minimax_url
          "#{::Gitlab::Utils.append_path(HOST, ENGINES_PATH)}?GroupId=#{@group_id}"
        end

        def headers
          { 'Content-Type': 'application/json', Authorization: "Bearer #{@api_key}" }
        end
      end
    end
  end
end
