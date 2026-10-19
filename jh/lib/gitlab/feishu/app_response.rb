# frozen_string_literal: true

module Gitlab
  module Feishu
    module AppResponse
      Error = Class.new(StandardError)
      TransientError = Class.new(Error)
      PermanentError = Class.new(Error)
      TokenRejected = Class.new(Error)

      class RateLimited < TransientError
        attr_reader :retry_after

        def initialize(message = nil, retry_after: nil)
          super(message)
          @retry_after = retry_after
        end
      end

      TOKEN_REJECTED_CODES = [99991663, 99991665].freeze
      TRANSIENT_CODES = [1500, 1503, 5000, 230049].freeze
      # 99991400 is the gateway limit that older endpoints return with HTTP 400; 230020 is the messaging limit.
      RATE_LIMITED_CODES = [99991400, 230020].freeze
      RETRY_AFTER_HEADERS = %w[Retry-After x-ogw-ratelimit-reset].freeze
      # A longer wait would outlast the one-hour UUID window that the send worker's deadline enforces.
      MAX_RETRY_AFTER = 1.hour.to_i

      def self.parse(response)
        status = response.code.to_i
        raise TransientError, "Feishu returned HTTP #{status}" if status >= 500 || status == 408
        raise rate_limited(response, "HTTP #{status}") if status == 429

        body = ::Gitlab::Json::SafeParser.parse(response.body)
        unless body.is_a?(Hash) && body['code'].is_a?(Integer)
          raise PermanentError, 'Feishu returned an invalid response'
        end

        code = body['code']
        raise TokenRejected, "Feishu rejected the token: code=#{code}" if TOKEN_REJECTED_CODES.include?(code)
        raise rate_limited(response, "code=#{code}") if RATE_LIMITED_CODES.include?(code)
        raise TransientError, "Feishu is temporarily unavailable: code=#{code}" if TRANSIENT_CODES.include?(code)
        raise PermanentError, "Feishu refused the request: code=#{code}" unless code == 0 && response.success?

        body
      rescue ::JSON::ParserError
        raise TransientError, 'Feishu returned malformed JSON'
      end

      def self.rate_limited(response, detail)
        RateLimited.new("Feishu rate limited the app: #{detail}", retry_after: retry_after(response))
      end
      private_class_method :rate_limited

      def self.retry_after(response)
        seconds = RETRY_AFTER_HEADERS
          .filter_map { |header| Integer(response.headers[header].to_s.strip, 10, exception: false) }
          .find(&:positive?)
        seconds&.clamp(1, MAX_RETRY_AFTER)
      end
      private_class_method :retry_after
    end
  end
end
