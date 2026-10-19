# frozen_string_literal: true

module Gitlab
  module Chatops
    class FeishuBotHandler < BaseBotHandler
      AuthenticationError = Class.new(StandardError)

      FEATURE_NAME = :feishu_bot_integration
      PLATFORM_NAME = 'Feishu'

      # Re-pushes (15s, 5m, 1h, 6h) are freshly signed, so the window only absorbs
      # clock skew while the claim outlives the whole re-push schedule.
      # https://open.feishu.cn/document/server-docs/event-subscription-guide/overview
      REQUEST_MAX_AGE = 5.minutes
      GO_TIME_PREFIX = /\A\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+ [+-]\d{4}/
      EVENT_CLAIM_KEY_PREFIX = "feishu-bot/event-id"
      EVENT_CLAIM_TTL = 8.hours

      # No `team_id`, `team_domain`, `user_name` support in the Feishu message event
      BIND_TEAM_ID = "feishu_team_id"
      BIND_TEAM_DOMAIN = "feishu_team_domain"
      BIND_USER_NAME = "Feishu Bot"

      # Feishu have no response url, this is for placeholder, we need use new http client to send response
      RESPONDER_RESPONSE_URL = "https://open.feishu.cn"
      URL_VERIFICATION_TYPE = "url_verification"
      CARD_ACTION_EVENT_TYPE = "card.action.trigger"

      BOT_OPEN_ID_CACHE_TIME = 1.day

      def initialize(params, headers, raw_body)
        super(params, headers)
        @raw_body = raw_body.to_s
      end

      # Nothing, including the replies sent on validation failures, may act on
      # the payload before it is authenticated.
      def execute
        authenticate_request!
        # A card button click arrives through the same verified callback but
        # is answered with a toast, not a ChatOps reply.
        return card_action_response if params.dig(:header, :event_type) == CARD_ACTION_EVENT_TYPE

        super
      end

      private

      attr_reader :raw_body

      ##
      # Override started
      #
      # Non-command messages addressed to the robot route to Duo Agent Platform
      # behind the flag; everything else keeps the original ChatOps behavior.
      def reply_message
        return super unless duo_chat_message?

        enqueue_duo_message

        nil
      end

      ##
      # Override ended
      #

      def card_action_response
        ::Ai::Messaging::FeishuApprovalActionService.new(
          operator_user_id: params.dig(:event, :operator, :user_id),
          value: params.dig(:event, :action, :value)
        ).execute
      end

      def duo_chat_message?
        return false unless ::Feature.enabled?(:jh_feishu_duo_chat, chat_name.user)
        return false if help?
        return false unless chat_name.user.active?
        return false unless params.dig(:event, :message, :message_type) == 'text'
        return false unless addressed_to_bot?
        # A bare @mention leaves nothing to ask, and as a decision it would
        # reject a pending action the user never meant to answer.
        return false if duo_message_text.blank?

        !chatops_command?
      end

      # Feishu pushes every group message to an app granted
      # im:message.group_msg, so in a group only a message that @mentions the
      # robot is a request; anything else is people talking to each other.
      def addressed_to_bot?
        return true unless group_message?

        mentions.any? { |mention| bot_mention?(mention) }
      end

      def bot_mention?(mention)
        bot_open_id.present? && mention.dig(:id, :open_id) == bot_open_id
      end

      # Nil when Feishu cannot say, which leaves group messages to ChatOps
      # rather than treating a message to someone else as a request.
      def bot_open_id
        @bot_open_id ||= Rails.cache.fetch(
          "feishu:duo:bot_open_id:#{::Gitlab::CurrentSettings.feishu_app_key}",
          expires_in: BOT_OPEN_ID_CACHE_TIME, skip_nil: true
        ) { Gitlab::Feishu::BotClient.new.bot_open_id }
      rescue Gitlab::Feishu::AppResponse::Error => e
        Gitlab::ErrorTracking.track_exception(e)
        nil
      end

      # Feishu answers a callback it does not see acknowledged within three
      # seconds by pushing it again, so the turn runs in a worker. A failed
      # enqueue raises, and the error response makes Feishu push it again --
      # once the event id process_repeat_event! claimed is released.
      def enqueue_duo_message
        message = params.dig(:event, :message)

        ::Feishu::DuoMessageWorker.perform_async(
          chat_name.user_id,
          {
            'app_id' => params.dig(:header, :app_id),
            'chat_id' => message[:chat_id],
            'thread_id' => message[:thread_id],
            'sender_id' => sender_user_id,
            'message_id' => message[:message_id],
            'text' => duo_message_text
          }.compact
        )
      rescue StandardError
        ::Gitlab::Redis::SharedState.with { |redis| redis.del(event_claim_key) }
        raise
      end

      # The robot's mention goes; anyone else's reads as their name, which is
      # what the user saw when they wrote it. Longest key first, so @_user_1
      # never eats the start of @_user_10.
      def duo_message_text
        @duo_message_text ||= mentions.sort_by { |mention| -mention[:key].to_s.length }
          .reduce(message_content['text'].to_s) do |text, mention|
            text.gsub(mention[:key].to_s, bot_mention?(mention) ? '' : "@#{mention[:name]}")
          end.strip
      end

      def mentions
        Array(params.dig(:event, :message, :mentions))
      end

      # https://open.feishu.cn/document/server-docs/event-subscription-guide/event-subscription-configure-/encrypt-key-encryption-configuration-case
      # Only encrypted callbacks are accepted: without an Encrypt Key Feishu sends
      # no signature, so nothing would bind the timestamp to the payload.
      def authenticate_request!
        if app_id.blank? || verification_token.blank? || encrypt_key.blank?
          raise AuthenticationError, 'App ID, Verification Token or Encrypt Key is not configured'
        end

        @params = decrypt_payload(params[:encrypt])

        # Feishu does not sign the URL verification request; the token inside the
        # encrypted body is what proves its origin.
        if params[:type] == URL_VERIFICATION_TYPE
          verify_token!(params[:token])
          return
        end

        verify_signature!
        verify_timestamp!
        verify_token!(params.dig(:header, :token))
        raise AuthenticationError, 'App ID mismatch' unless params.dig(:header, :app_id) == app_id
        raise AuthenticationError, 'Missing event ID' if params.dig(:header, :event_id).blank?
      end

      def decrypt_payload(encrypted)
        raise AuthenticationError, 'Callback is not encrypted' unless encrypted.is_a?(String)

        data = Base64.strict_decode64(encrypted)
        raise AuthenticationError, 'Malformed ciphertext' if data.bytesize < 32 || data.bytesize % 16 != 0

        cipher = OpenSSL::Cipher.new('aes-256-cbc').decrypt
        cipher.key = OpenSSL::Digest::SHA256.digest(encrypt_key)
        cipher.iv = data.byteslice(0, 16)
        plaintext = (cipher.update(data.byteslice(16..)) + cipher.final).force_encoding(Encoding::UTF_8)

        payload = Gitlab::Json.parse(plaintext)
        raise AuthenticationError, 'Malformed payload' unless payload.is_a?(Hash)

        payload.with_indifferent_access
      rescue ArgumentError, OpenSSL::Cipher::CipherError, JSON::ParserError
        raise AuthenticationError, 'Undecryptable payload'
      end

      def verify_signature!
        signature = headers['x-lark-signature'].to_s
        signed = [headers['x-lark-request-timestamp'], headers['x-lark-request-nonce'], encrypt_key].join.b
        expected = OpenSSL::Digest::SHA256.hexdigest(signed + raw_body.b)

        return if ActiveSupport::SecurityUtils.secure_compare(expected, signature)

        raise AuthenticationError, 'Signature mismatch'
      end

      def verify_timestamp!
        timestamp = request_time(headers['x-lark-request-timestamp'].to_s)
        raise AuthenticationError, 'Malformed timestamp' unless timestamp
        return if (Time.current.to_i - timestamp).abs <= REQUEST_MAX_AGE

        raise AuthenticationError, 'Stale request'
      end

      # Events send Unix seconds. Card callbacks send Go's Time#String, e.g.
      # "2026-10-10 16:29:52.549803051 +0800 CST m=+12.3", signed as is.
      def request_time(value)
        return value.to_i if value.match?(/\A\d+\z/)

        match = value.match(GO_TIME_PREFIX)
        Time.strptime(match[0], '%Y-%m-%d %H:%M:%S.%N %z').to_i if match
      rescue ArgumentError
        nil
      end

      def verify_token!(token)
        return if token.is_a?(String) && ActiveSupport::SecurityUtils.secure_compare(token, verification_token)

        raise AuthenticationError, 'Verification Token mismatch'
      end

      def process_url_verification!
        return unless params[:type] == URL_VERIFICATION_TYPE

        response = { challenge: params[:challenge] }
        raise UrlVerificationError.new(nil, response)
      end

      # Claimed only after authentication, so a forged request cannot burn a real
      # event ID. Kept even when processing fails: the command may have run partway,
      # so a re-push is dropped rather than risk running it twice.
      def process_repeat_event!
        claimed = ::Gitlab::Redis::SharedState.with do |redis|
          redis.set(event_claim_key, 1, ex: EVENT_CLAIM_TTL.to_i, nx: true)
        end

        raise RepeatEventError unless claimed
      end

      def event_claim_key
        "#{EVENT_CLAIM_KEY_PREFIX}/#{app_id}/#{params.dig(:header, :event_id)}"
      end

      def process_response(response)
        # Nothing to reply synchronously: the Duo turn answers on its own.
        return if response.blank?

        # Feishu will metion user by the string content `<at user_id="xxx"></at>`,
        # but `to_json` will encode the `<`, `>`.
        # See more in: https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/im-v1/message/create_json
        body = Gitlab::Json.generate(response).gsub("\\\\u003c", "<").gsub("\\\\u003e", ">")
        http_client.send_message(body, type: nil)

        nil
      end

      # The app ID is checked in authenticate_request!, before any reply is sent.
      def valid_message?
        true
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
        # Feishu text: `{ "text": "@_user_1 help" }`, we need remove the ping text
        @command_message ||= message_content["text"].to_s.gsub(/@\w+ /, "")
      end

      def message_content
        @message_content ||= begin
          content = Gitlab::Json.parse(params.dig(:event, :message, :content))
          content.is_a?(Hash) ? content : {}
        rescue StandardError
          {}
        end
      end

      def bind_url
        ::ChatNames::AuthorizeUserService.new(
          {
            team_id: BIND_TEAM_ID,
            team_domain: BIND_TEAM_DOMAIN,
            user_id: sender_user_id,
            user_name: BIND_USER_NAME
          }).execute
      end

      def chat_name
        @chat_name ||= ::ChatNames::FindUserService.new(BIND_TEAM_ID, sender_user_id).execute
      end

      def sender_user_id
        params.dig(:event, :sender, :sender_id, :user_id)
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

      def app_id
        ::Gitlab::CurrentSettings.feishu_app_key
      end

      def verification_token
        integration&.verification_token
      end

      def encrypt_key
        integration&.encrypt_key
      end
    end
  end
end
