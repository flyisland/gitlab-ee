# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Feishu
      def request_phase
        return fail!(:invalid_credentials) if ::Gitlab.com?

        super
      end

      def callback_phase
        return fail!(:invalid_credentials) if ::Gitlab.com?

        super
      rescue ::Gitlab::HTTP::BlockedUrlError, *::Gitlab::HTTP::HTTP_ERRORS
        fail!(:invalid_credentials)
      end

      protected

      def parse_json(raw)
        ::Gitlab::Json::SafeParser.parse(raw)
      end

      def request_token(params)
        response = ::Gitlab::HTTP.post(
          client.token_url,
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          body: URI.encode_www_form(params),
          timeout: 10, follow_redirects: false
        )
        [response.code, response.body]
      end

      def request_user_info
        response = ::Gitlab::HTTP.get(
          "#{client.site}#{USER_INFO_PATH}",
          headers: { 'Authorization' => "Bearer #{access_token.token}" },
          timeout: 10, follow_redirects: false
        )
        [response.code, response.body]
      end
    end
  end
end
