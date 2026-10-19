# frozen_string_literal: true

module Gitlab
  module Feishu
    # Robot replies and CardKit cards for Duo in Feishu, sent as the ChatOps
    # robot's app (BotApp). Raises AppResponse errors; callers decide what a
    # failed delivery means for them.
    #
    # https://open.feishu.cn/document/cardkit-v1/streaming-updates-openapi-overview
    class BotClient
      BOT_INFO_PATH = '/open-apis/bot/v3/info'
      REPLY_PATH = '/open-apis/im/v1/messages/%{message_id}/reply'
      CARDS_PATH = '/open-apis/cardkit/v1/cards'
      CARD_PATH = '/open-apis/cardkit/v1/cards/%{card_id}'
      CARD_ELEMENT_CONTENT_PATH = '/open-apis/cardkit/v1/cards/%{card_id}/elements/%{element_id}/content'
      IMAGES_PATH = '/open-apis/im/v1/images'

      # 200850: streaming timed out (it closes 10 minutes after it was enabled);
      # 300309: streaming is off. Both mean only a full card update can still
      # change the card.
      STREAMING_CLOSED_CODES = [200850, 300309].freeze

      TransientError = AppResponse::TransientError
      PermanentError = AppResponse::PermanentError
      StreamingClosedError = Class.new(PermanentError)

      def initialize(app: BotApp)
        @app = app
      end

      # The robot's own open_id, which is how a group message @mentioning it
      # names it.
      def bot_open_id
        body = with_token_retry { request(Net::HTTP::Get, BOT_INFO_PATH) }

        body.dig('bot', 'open_id').presence
      end

      # Answers the message the user sent. Within an hour, a repeated uuid
      # posts nothing new, so a retried delivery cannot answer twice.
      def reply(message_id, msg_type:, content:, uuid:)
        with_token_retry do
          request(
            Net::HTTP::Post,
            format(REPLY_PATH, message_id: message_id),
            body: { msg_type: msg_type, content: ::Gitlab::Json.generate(content), uuid: uuid }
          )
        end
      end

      # Creates a card entity from card JSON 2.0 and returns its id. The card
      # appears in a conversation only once it is sent with #reply.
      def create_card(card)
        body = with_token_retry do
          request(Net::HTTP::Post, CARDS_PATH, body: { type: 'card_json', data: ::Gitlab::Json.generate(card) })
        end

        body.dig('data', 'card_id').presence ||
          raise(PermanentError, 'Feishu returned no card id')
      end

      # Rewrites one text element of a card in streaming mode. Text that
      # extends what is shown types out; anything else replaces it at once.
      # sequence must exceed every earlier one on the card.
      def stream_card_text(card_id, element_id, content, sequence:)
        with_token_retry do
          request(
            Net::HTTP::Put,
            format(CARD_ELEMENT_CONTENT_PATH, card_id: card_id, element_id: element_id),
            body: { content: content, sequence: sequence }
          )
        end
      end

      # Uploads an image messages and cards can show, and returns its key.
      def upload_image(file)
        body = with_token_retry do
          file.rewind
          request(Net::HTTP::Post, IMAGES_PATH, form: { image_type: 'message', image: file })
        end

        body.dig('data', 'image_key').presence ||
          raise(PermanentError, 'Feishu returned no image key')
      end

      # Replaces the whole card, whatever its streaming state.
      def update_card(card_id, card, sequence:)
        with_token_retry do
          request(
            Net::HTTP::Put,
            format(CARD_PATH, card_id: card_id),
            body: { card: { type: 'card_json', data: ::Gitlab::Json.generate(card) }, sequence: sequence }
          )
        end
      end

      private

      attr_reader :app

      def with_token_retry
        retried = false
        begin
          parse(yield)
        rescue AppResponse::TokenRejected
          raise TransientError, 'Feishu kept rejecting the access token' if retried

          retried = true
          app.invalidate_access_token
          retry
        end
      end

      def parse(response)
        body = ::Gitlab::Json::SafeParser.parse(response.body.to_s)
        if body.is_a?(Hash) && STREAMING_CLOSED_CODES.include?(body['code'])
          raise StreamingClosedError, "Feishu card streaming is closed: code=#{body['code']}"
        end

        AppResponse.parse(response)
      rescue ::JSON::ParserError
        AppResponse.parse(response)
      end

      def request(method, path, body: nil, form: nil)
        headers = { 'Authorization' => "Bearer #{app.access_token}" }
        options = { headers: headers, timeout: 10, follow_redirects: false }

        if form
          options[:body] = form
          options[:multipart] = true
        else
          headers['Content-Type'] = 'application/json; charset=utf-8'
          options[:body] = ::Gitlab::Json.generate(body) if body
        end

        ::Gitlab::HTTP.perform_request(method, "#{app.api_site}#{path}", options)
      rescue ::Gitlab::HTTP::BlockedUrlError
        raise PermanentError, 'Feishu endpoint is blocked'
      rescue *::Gitlab::HTTP::HTTP_ERRORS
        raise TransientError, 'Feishu request failed'
      end
    end
  end
end
