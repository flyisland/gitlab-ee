# frozen_string_literal: true

module Gitlab
  module Feishu
    class Client
      ACCESS_TOKEN_ENDPOINT = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
      MESSAGE_ENDPOINT = "https://open.feishu.cn/open-apis/im/v1/messages"
      QUERY_BOT_ENDPOINT = "https://open.feishu.cn/open-apis/im/v1/chats"

      def self.build
        new(app_key: ::Gitlab::CurrentSettings.feishu_app_key, app_secret: ::Gitlab::CurrentSettings.feishu_app_secret)
      end

      def initialize(params)
        @app_key = params[:app_key]
        @app_secret = params[:app_secret]
      end

      def send_message(body, type: :user)
        token = access_token

        return if token.blank?

        response = Gitlab::HTTP.perform_request(
          Net::HTTP::Post,
          message_url(type),
          {
            headers: {
              'Content-Type' => 'application/json; charset=utf-8',
              'Authorization' => "Bearer #{token}"
            },
            body: body
          }
        )

        response if response_success?(response)
      rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        Gitlab::AppLogger.error(e.message.to_s)
        nil
      end

      def groups_contains_bot
        token = access_token

        return if token.blank?

        response = Gitlab::HTTP.perform_request(
          Net::HTTP::Get,
          # assume one bot cannot join more than 100 feishu group
          "#{QUERY_BOT_ENDPOINT}?page_size=100",
          {
            headers: {
              'Content-Type' => 'application/json; charset=utf-8',
              'Authorization' => "Bearer #{token}"
            }
          }
        )

        response_success?(response)

        @body['data']['items'].each_with_object({}) { |data, memo| memo[data['name']] = data['chat_id'] }
      rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        Gitlab::AppLogger.error(e.message.to_s)
        nil
      end

      private

      def response_success?(response)
        @body = Gitlab::Json.parse(response.body)
        code = @body&.dig('code')
        msg = @body&.dig('msg')
        if !response.success? || code != 0
          raise Gitlab::HTTP::Error,
            "GitLab:: FeiShu client error, url:#{response.request.uri}, code: #{code}, msg: #{msg}"
        else
          true
        end
      end

      def message_url(type)
        "#{MESSAGE_ENDPOINT}?receive_id_type=#{type == :user ? :user_id : :chat_id}"
      end

      def cache_key
        "integration:feishu_#{@app_key}_access_token"
      end

      def access_token
        token = Rails.cache.read(cache_key)
        return Gitlab::CryptoHelper.aes256_gcm_decrypt(token) if token.present?

        response = Gitlab::HTTP.perform_request(
          Net::HTTP::Post,
          ACCESS_TOKEN_ENDPOINT,
          {
            headers: { 'Content-Type' => 'application/json; charset=utf-8' },
            body: Gitlab::Json.generate({ app_id: @app_key, app_secret: @app_secret })
          })

        response_success?(response)

        encrypted_token = Gitlab::CryptoHelper.aes256_gcm_encrypt(@body['tenant_access_token'])
        Rails.cache.write(cache_key, encrypted_token, expires_in: @body['expire'].to_i)
        @body['tenant_access_token']
      rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        Gitlab::AppLogger.error(e.message.to_s)
        nil
      end
    end
  end
end
