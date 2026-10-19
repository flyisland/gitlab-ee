# frozen_string_literal: true

module Gitlab
  module Dingtalk
    module AppResponse
      Error = Class.new(StandardError)
      TransientError = Class.new(Error)
      PermanentError = Class.new(Error)
      TokenRejected = Class.new(Error)
      TOKEN_REJECTED_CODES = [40014, 42001].freeze

      def self.parse(response, token: false)
        status = response.code.to_i
        raise TransientError, "DingTalk returned HTTP #{status}" if status >= 500 || status == 408
        raise PermanentError, "DingTalk returned HTTP #{status}" unless response.success?

        body = ::Gitlab::Json::SafeParser.parse(response.body)
        raise PermanentError, 'DingTalk returned an invalid response' unless body.is_a?(Hash)
        return body if token && body['accessToken'].is_a?(String) && body['accessToken'].present?

        code = body['errcode']
        return body if code == 0
        raise TokenRejected, 'DingTalk rejected the access token' if TOKEN_REJECTED_CODES.include?(code)
        raise TransientError, 'DingTalk is busy' if code == -1

        raise PermanentError, 'DingTalk refused the request'
      rescue ::JSON::ParserError
        raise TransientError, 'DingTalk returned malformed JSON', cause: nil
      end
    end
  end
end
