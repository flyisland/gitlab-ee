# frozen_string_literal: true

module Gitlab
  module Chatops
    class FeishuBotHandler < BaseBotHandler
      FEATURE_NAME = :feishu_bot_integration
      PLATFORM_NAME = 'Feishu'

      EVENT_CACHE_KEY_PREFIX = "feishu-bot/event-id"
      EVENT_CACHE_TIME = 7.5.hours

      # No `team_id`, `team_domain`, `user_name` support in the Feishu message event
      BIND_TEAM_ID = "feishu_team_id"
      BIND_TEAM_DOMAIN = "feishu_team_domain"
      BIND_USER_NAME = "Feishu Bot"

      # Feishu have no response url, this is for placeholder, we need use new http client to send response
      RESPONDER_RESPONSE_URL = "https://open.feishu.cn"
      URL_VERIFICATION_TYPE = "url_verification"

      private

      def process_url_verification!
        return unless params[:type] == URL_VERIFICATION_TYPE

        response = { challenge: params[:challenge] }
        raise UrlVerificationError.new(nil, response)
      end

      # https://open.feishu.cn/document/ukTMukTMukTM/uUTNz4SN1MjL1UzM#1783f79c
      def process_repeat_event!
        event_id = params.dig(:header, :event_id)
        return unless event_id.present?

        cache_key = "#{EVENT_CACHE_KEY_PREFIX}/#{event_id}"
        raise RepeatEventError if Rails.cache.exist?(cache_key)

        Rails.cache.write(cache_key, true, expires_in: EVENT_CACHE_TIME)
      end

      def process_response(response)
        # Feishu will metion user by the string content `<at user_id="xxx"></at>`,
        # but `to_json` will encode the `<`, `>`.
        # See more in: https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/im-v1/message/create_json
        body = Gitlab::Json.generate(response).gsub("\\\\u003c", "<").gsub("\\\\u003e", ">")
        http_client.send_message(body, type: nil)

        nil
      end

      def valid_message?
        params.dig(:header, :app_id) == ::Gitlab::CurrentSettings.feishu_app_key
      end

      def send_bind_link_message
        body = {
          receive_id: receive_id,
          msg_type: "post",
          content: Gitlab::Json.generate({
            "zh-cn": {
              title: s_("JH|Chatops|Please connect your JiHu GitLab account"),
              content: [
                [{ tag: "a", href: bind_url,
                   text: s_("JH|Chatops|Click to process") }]
              ]
            }
          })
        }

        http_client.send_message(Gitlab::Json.generate(body), type: nil)
      end

      def responder
        {
          channel: receive_id,
          response_url: RESPONDER_RESPONSE_URL
        }
      end

      def command_message
        @command_message ||= begin
          content = begin
            Gitlab::Json.parse(params.dig(:event, :message, :content))
          rescue StandardError
            {}
          end

          # Feishu text: `{ "text": "@_user_1 help" }`, we need remove the ping text
          content["text"].to_s.gsub(/@\w+ /, "")
        end
      end

      def bind_url
        ::ChatNames::AuthorizeUserService.new(
          {
            team_id: BIND_TEAM_ID,
            team_domain: BIND_TEAM_DOMAIN,
            user_id: params.dig(:event, :sender, :sender_id, :user_id),
            user_name: BIND_USER_NAME
          }).execute
      end

      def chat_name
        @chat_name ||= ::ChatNames::FindUserService.new(
          BIND_TEAM_ID,
          params.dig(:event, :sender, :sender_id, :user_id)
        ).execute
      end

      def integration
        @integration ||= ::Integrations::FeishuBot.for_instance.first
      end

      def setting_enabled?
        ::Gitlab::CurrentSettings.feishu_bot_enabled?
      end

      def group_message?
        params.dig(:event, :message, :chat_type) == "group"
      end

      def formatter_class
        Gitlab::Feishu::Formatter
      end

      def feature_name
        FEATURE_NAME
      end

      def platform_name
        PLATFORM_NAME
      end

      def http_client
        @http_client ||= Gitlab::Feishu::Client.build
      end

      def receive_id
        params.dig(:event, :message, :chat_id)
      end
    end
  end
end
