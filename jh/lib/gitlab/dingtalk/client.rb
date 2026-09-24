# frozen_string_literal: true

module Gitlab
  module Dingtalk
    class Client
      ACCESS_TOKEN_ENDPOINT = "https://api.dingtalk.com/v1.0/oauth2/accessToken"
      USER_MESSAGE_ENDPOINT = "https://api.dingtalk.com/v1.0/robot/oToMessages/batchSend"
      GROUP_MESSAGE_ENDPOINT = "https://api.dingtalk.com/v1.0/robot/groupMessages/send"

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

      private

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
