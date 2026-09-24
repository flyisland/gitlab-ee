# frozen_string_literal: true

module Gitlab
  module Chatops
    class DingtalkBotHandler < BaseBotHandler
      FEATURE_NAME = :dingtalk_integration
      PLATFORM_NAME = 'Dingtalk'

      private

      def process_url_verification!
        nil
      end

      def process_repeat_event!
        nil
      end

      ##
      # Override started
      #
      def valid_message?
        secret = ::Gitlab::CurrentSettings.dingtalk_app_secret || ''
        content = "#{headers['Timestamp']}\n#{secret}"
        sign = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('SHA256'), secret, content)).strip
        sign == headers['Sign']
      end

      def send_bind_link_message
        body = {
          robotCode: ::Gitlab::CurrentSettings.dingtalk_app_key,
          userIds: [params[:senderStaffId]],
          msgKey: 'sampleLink',
          msgParam: Gitlab::Json.generate({
            text: s_("JH|Chatops|Click to process"),
            title: s_("JH|Chatops|Please connect your JiHu GitLab account"),
            messageUrl: bind_url
          })
        }

        http_client.send_message(Gitlab::Json.generate(body))
      end

      def responder
        {
          channel: params[:conversationId],
          response_url: params[:sessionWebhook]
        }
      end

      def command_message
        @command_message ||= params[:text].try(:[], :content).try(:strip)
      end

      def bind_url
        ::ChatNames::AuthorizeUserService.new(
          {
            team_id: params[:senderCorpId],
            team_domain: params[:senderCorpId],
            user_id: params[:senderStaffId],
            user_name: params[:senderNick]
          }).execute
      end

      def chat_name
        @chat_name ||= ::ChatNames::FindUserService.new(
          params[:chatbotCorpId],
          params[:senderStaffId]
        ).execute
      end

      def integration
        @integration ||= ::Integrations::Dingtalk.find_by_corpid(params[:chatbotCorpId])
      end

      def setting_enabled?
        ::Gitlab::CurrentSettings.dingtalk_enabled?
      end

      def group_message?
        params[:conversationType] == '2'
      end

      def formatter_class
        Gitlab::Dingtalk::Formatter
      end

      def feature_name
        FEATURE_NAME
      end

      def platform_name
        PLATFORM_NAME
      end

      def http_client
        @http_client ||= ::Gitlab::Dingtalk::Client.new(
          {
            corpid: ::Gitlab::CurrentSettings.dingtalk_corpid,
            app_secret: ::Gitlab::CurrentSettings.dingtalk_app_secret,
            app_key: ::Gitlab::CurrentSettings.dingtalk_app_key
          }
        )
      end
    end
  end
end
