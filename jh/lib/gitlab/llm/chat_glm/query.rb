# frozen_string_literal: true

# need to be compatible with Gitlab::Llm::OpenAi::Client

module Gitlab
  module Llm
    module ChatGlm
      class Query
        def initialize(user, _options: {})
          @user = user
          @logger = Gitlab::Llm::Logger.build
        end

        def chat(content:, **options)
          request(:chat, prompt: content, **options.slice(:temperature, :parsed_response))
        end

        def chat_v3(content:, **options)
          request(:chat_v3, prompt: content, **options.slice(:temperature, :parsed_response))
        end

        private

        attr_reader :user, :logger

        def client
          @client ||= ChatGlm::Client.new(api_key: api_key)
        end

        def enabled?
          api_key.present?
        end

        def api_key
          ENV['CHAT_GLM_API_KEY']
        end

        def request(endpoint = :chat, **options)
          logger.debug(message: "Performing request to ChatGLM: enabled?:#{enabled?} #{endpoint} #{options}",
            klass: to_s, event_name: 'chatglm', ai_component: 'abstraction_layer')
          return unless enabled?

          response = client.public_send(endpoint, **options) # rubocop:disable GitlabSecurity/PublicSend
          logger.debug(message: "Received response from ChatGLM: #{response}", klass: to_s, event_name: 'chatglm',
            ai_component: 'abstraction_layer')

          response
        end
      end
    end
  end
end
