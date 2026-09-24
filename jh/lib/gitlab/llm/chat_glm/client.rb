# frozen_string_literal: true

require 'jwt'

module Gitlab
  module Llm
    module ChatGlm
      class Client
        HOST = 'https://maas.aminer.cn'
        BASE_PATH = '/api/paas/'
        ENGINES_PATH = '/model/v1/open/engines'

        V3_HOST = 'https://open.bigmodel.cn'
        V3_ENGINES_PATH = '/v3/model-api/chatglm_pro/invoke'

        AUTH_TOKEN_EXPIRATION = 30 * 1000 # millisecond
        AUTH_TOKEN_JWT_ALG = 'HS256'

        DEFAULT_TEMPERATURE = 0.6

        Error = Class.new(StandardError)

        def initialize(api_key:)
          @api_id, @api_secret = api_key.to_s.split('.')

          raise Error, 'invalid configuration' unless @api_id.present? && @api_secret.present?
        end

        def chat(options)
          default_options = { temperature: DEFAULT_TEMPERATURE, prompt: '', history: [] }

          response = ::Gitlab::HTTP.post(chat_glm_url, body: default_options.merge(options).to_json, headers: headers)

          options[:parsed_response] ? response.parsed_response : response.body
        rescue *Gitlab::HTTP::HTTP_ERRORS => e
          raise Error, "request chat failed: #{e.message}"
        end

        def chat_v3(options)
          default_options = { temperature: DEFAULT_TEMPERATURE, prompt: '' }

          response = ::Gitlab::HTTP.post(chat_glm_v3_url, body: default_options.merge(options).to_json,
            headers: headers)

          options[:parsed_response] ? response.parsed_response : response.body
        rescue *Gitlab::HTTP::HTTP_ERRORS => _e
          raise Error, 'request chat failed'
        end

        private

        attr_reader :api_id, :api_secret

        def base_url
          ::Gitlab::Utils.append_path(HOST, BASE_PATH)
        end

        def engines_url
          ::Gitlab::Utils.append_path(base_url, ENGINES_PATH)
        end

        def chat_glm_url
          ::Gitlab::Utils.append_path(engines_url, 'chatGLM/chatGLM')
        end

        def chat_glm_v3_url
          base = ::Gitlab::Utils.append_path(V3_HOST, BASE_PATH)
          ::Gitlab::Utils.append_path(base, V3_ENGINES_PATH)
        end

        def headers
          { 'Content-Type': 'application/json', Authorization: auth_token }
        end

        def auth_token
          current_at = (Time.now.to_f * 1000).to_i # millisecond

          JWT.encode(
            { api_key: api_id, timestamp: current_at, exp: current_at + AUTH_TOKEN_EXPIRATION },
            api_secret,
            AUTH_TOKEN_JWT_ALG,
            { sign_type: "SIGN" }
          )
        end
      end
    end
  end
end
