# frozen_string_literal: true

module Gitlab
  module Wecom
    class Client
      MESSAGE_ENDPOINT = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send'

      def initialize; end

      def send_message(body, channel)
        response = Gitlab::HTTP.perform_request(
          Net::HTTP::Post,
          message_url(channel),
          {
            headers: {
              'Content-Type' => 'application/json'
            },
            body: body
          }
        )

        response if response_success?(response)
      rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        Gitlab::AppLogger.error(e.message.to_s)
        nil
      end

      private

      def response_success?(response)
        body = Gitlab::Json.parse(response.body)
        code = body&.dig('errcode')
        msg = body&.dig('errmsg')
        if !response.success? || code != 0
          raise Gitlab::HTTP::Error,
            "GitLab:: Wecom client error, url:#{response.request.uri}, code: #{code}, msg: #{msg}"
        else
          true
        end
      end

      def message_url(channel)
        "#{MESSAGE_ENDPOINT}?key=#{channel}"
      end
    end
  end
end
