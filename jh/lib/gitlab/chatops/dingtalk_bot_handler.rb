# frozen_string_literal: true

module Gitlab
  module Chatops
    class DingtalkBotHandler < BaseBotHandler
      FEATURE_NAME = :dingtalk_integration
      PLATFORM_NAME = 'Dingtalk'
      MSG_ID_CACHE_KEY_PREFIX = 'dingtalk-bot/msg-id'
      MSG_ID_CACHE_TIME = 1.hour

      private

      ##
      # Override started
      #
      # Non-command messages route to Duo Agent Platform behind the flag;
      # everything else keeps the original ChatOps behavior.
      def reply_message
        return super unless ::Feature.enabled?(:jh_dingtalk_duo_chat, chat_name.user)
        return super if help?
        return super unless chat_name.user.active?
        return super if chatops_command?

        duo_trigger_message
      end

      # Nil means the user was already answered asynchronously (e.g. a delivered
      # error) and the webhook response stays empty.
      def duo_trigger_message
        # A webhook carries no session, so without this every reply falls back to
        # the default locale -- English acknowledgements for a Chinese speaker.
        text = ::Gitlab::I18n.with_user_locale(chat_name.user) do
          ::Ai::Messaging::DingtalkTriggerService.new(
            user: chat_name.user,
            corp_id: params[:chatbotCorpId],
            conversation_id: params[:conversationId],
            conversation_type: params[:conversationType],
            sender_staff_id: params[:senderStaffId],
            message: command_message
          ).execute
        end

        { type: :text, content: text } if text
      end

      ##
      # Override ended
      #

      def process_url_verification!
        nil
      end

      # The base class calls this before the signature is checked, which is too
      # early to claim anything: an unsigned request could burn the msgId of a
      # message that has not arrived yet. Deduplication runs from validate_data!.
      def process_repeat_event!
        nil
      end

      def validate_data!
        super

        reject_repeat_message!
      end

      # DingTalk re-delivers a message when the webhook is slow or errors, and a
      # replayed message runs the turn twice -- for a decision, approving an
      # action the user was never shown. Claimed atomically because two
      # re-deliveries can arrive at once.
      def reject_repeat_message!
        msg_id = params[:msgId]
        return if msg_id.blank?

        claimed = ::Gitlab::Redis::SharedState.with do |redis|
          redis.set(
            "#{MSG_ID_CACHE_KEY_PREFIX}/#{params[:chatbotCorpId]}/#{msg_id}",
            1, ex: MSG_ID_CACHE_TIME, nx: true
          )
        end

        raise RepeatEventError unless claimed
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
