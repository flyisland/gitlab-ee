# frozen_string_literal: true

module Gitlab
  module Dingtalk
    class Client
      ACCESS_TOKEN_ENDPOINT = "https://api.dingtalk.com/v1.0/oauth2/accessToken"
      USER_MESSAGE_ENDPOINT = "https://api.dingtalk.com/v1.0/robot/oToMessages/batchSend"
      GROUP_MESSAGE_ENDPOINT = "https://api.dingtalk.com/v1.0/robot/groupMessages/send"
      CARD_CREATE_ENDPOINT = "https://api.dingtalk.com/v1.0/card/instances/createAndDeliver"
      CARD_STREAMING_ENDPOINT = "https://api.dingtalk.com/v1.0/card/streaming"
      CARD_UPDATE_ENDPOINT = "https://api.dingtalk.com/v1.0/card/instances"
      CARD_CALLBACK_REGISTER_ENDPOINT = "https://api.dingtalk.com/v1.0/card/callbacks/register"

      def initialize(params)
        @corpid = params[:corpid]
        @app_key = params[:app_key]
        @app_secret = params[:app_secret]
      end

      def send_message(body, type: :user)
        token = access_token

        return if token.blank?

        Gitlab::HTTP.perform_request(
          Net::HTTP::Post,
          type == :user ? USER_MESSAGE_ENDPOINT : GROUP_MESSAGE_ENDPOINT,
          {
            headers: {
              'Content-Type' => 'application/json',
              'x-acs-dingtalk-access-token' => token
            },
            body: body
          }
        )
      rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        Gitlab::AppLogger.error("GitLab: DingTalk Integration Network error occurred: #{e.message}")
      end

      # Puts an interactive card in the conversation. The caller owns the
      # outTrackId in the body: every later update addresses the card by it,
      # so nothing from this response needs keeping.
      def create_card(body)
        card_request(Net::HTTP::Post, CARD_CREATE_ENDPOINT, body)
      end

      # Rewrites a streaming field of a card already delivered. The AI card
      # template leaves its "processing" state on the first of these and settles
      # on the last one, the one sent with isFinalize.
      def stream_card(body)
        card_request(Net::HTTP::Put, CARD_STREAMING_ENDPOINT, body)
      end

      # Rewrites ordinary (non-streaming) variables of a card already delivered,
      # leaving the ones the body does not name as they are.
      def update_card(out_track_id, card_params)
        card_request(Net::HTTP::Put, CARD_UPDATE_ENDPOINT, {
          outTrackId: out_track_id,
          cardData: { cardParamMap: card_params },
          cardUpdateOptions: { updateCardDataByKey: true }
        })
      end

      # Tells DingTalk where to post button clicks on cards delivered with this
      # route key, and the secret it signs them with.
      def register_card_callback(body)
        card_request(Net::HTTP::Post, CARD_CALLBACK_REGISTER_ENDPOINT, body)
      end

      private

      def card_request(method, endpoint, body)
        token = access_token

        return if token.blank?

        Gitlab::HTTP.perform_request(
          method,
          endpoint,
          {
            headers: {
              'Content-Type' => 'application/json',
              'x-acs-dingtalk-access-token' => token
            },
            body: Gitlab::Json.generate(body)
          }
        )
      rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        Gitlab::AppLogger.error("GitLab: DingTalk card request network error occurred: #{e.message}")
      end

      def cache_key
        "integration:dingtalk_#{@corpid}_access_token"
      end

      def access_token
        token = Rails.cache.read(cache_key)
        return Gitlab::CryptoHelper.aes256_gcm_decrypt(token) if token.present?

        begin
          response = Gitlab::HTTP.perform_request(
            Net::HTTP::Post,
            ACCESS_TOKEN_ENDPOINT,
            {
              headers: { 'Content-Type' => 'application/json' },
              body: Gitlab::Json.generate({ appKey: @app_key, appSecret: @app_secret })
            })
        rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
          Gitlab::AppLogger.error("GitLab: DingTalk ACCESS_TOKEN_ENDPOINT Network error occurred: #{e.message}")
          return
        end

        unless response.success?
          Gitlab::AppLogger.error("GitLab: DingTalk ACCESS_TOKEN_ENDPOINT response not success: #{response.inspect}")
          return
        end

        body = Gitlab::Json.parse(response.body)
        encrypted_token = Gitlab::CryptoHelper.aes256_gcm_encrypt(body['accessToken'])
        Rails.cache.write(cache_key, encrypted_token, expires_in: body['expireIn'].to_i)
        body['accessToken']
      end
    end
  end
end
