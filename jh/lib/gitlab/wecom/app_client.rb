# frozen_string_literal: true

module Gitlab
  module Wecom
    # Sends application messages to individual WeCom members.
    #
    # Failures are split into two kinds, because the caller has to treat them
    # differently: a transient failure is worth another attempt, a permanent one
    # never is and must not eat the retry budget.
    class AppClient
      MESSAGE_PATH = '/cgi-bin/message/send'

      # WeCom accepts at most this many recipients in one call.
      MAX_RECIPIENTS = 1000
      RECIPIENT_SEPARATOR = '|'

      # Asks WeCom to drop a message identical to one it already delivered
      # within the interval. Guards against a retry that follows a request which
      # actually arrived but whose response was lost.
      DUPLICATE_CHECK_INTERVAL = 30.minutes

      # The corp token itself was refused, so a fresh one may work. 41001 is
      # deliberately absent: it means the token was never sent, which refetching
      # does not fix.
      TOKEN_REJECTED_CODES = [40014, 42001].freeze

      # WeCom says "system busy, try again later".
      SYSTEM_BUSY_CODE = -1

      # The application hit an API frequency limit. WeCom's ban window can last
      # minutes, hours or a day, so an immediate Sidekiq retry would deepen the
      # throttling rather than recover from it. The notification is dropped and
      # logged instead.
      RATE_LIMITED_CODE = 45009

      # A request timed out upstream and is safe to repeat.
      RETRYABLE_HTTP_STATUS = [408].freeze

      Error = Class.new(StandardError)
      TransientError = Class.new(Error)
      PermanentError = Class.new(Error)

      # WeCom reports undeliverable recipients in an otherwise successful
      # response, so a caller cannot read "delivered" from the status alone.
      Result = Struct.new(:message_id, :invalid_user_ids, keyword_init: true) do
        def partial?
          invalid_user_ids.any?
        end
      end

      def initialize(app: ::Gitlab::Wecom::App)
        @app = app
      end

      # @param user_ids [Array<String>] WeCom UserIds
      # @param card [Hash] a template_card payload
      # @return [Result]
      def send_card(user_ids, card)
        recipients = Array(user_ids).compact.uniq
        raise ArgumentError, 'no recipients' if recipients.empty?

        if recipients.size > MAX_RECIPIENTS
          raise ArgumentError, "too many recipients: #{recipients.size} > #{MAX_RECIPIENTS}"
        end

        deliver(recipients, card)
      end

      private

      attr_reader :app

      def deliver(recipients, card, retried: false)
        body = parse(post(recipients, card))

        Result.new(
          message_id: body['msgid'],
          invalid_user_ids: split_recipients(body['invaliduser'])
        )
      rescue TokenRejected
        raise TransientError, 'WeCom kept rejecting the access token' if retried

        app.invalidate_access_token
        deliver(recipients, card, retried: true)
      end

      TokenRejected = Class.new(StandardError)
      private_constant :TokenRejected

      def post(recipients, card)
        token, = app.access_token

        ::Gitlab::HTTP.post(
          "#{app.api_site}#{MESSAGE_PATH}",
          query: { access_token: token },
          headers: { 'Content-Type' => 'application/json' },
          body: ::Gitlab::Json.generate(
            touser: recipients.join(RECIPIENT_SEPARATOR),
            msgtype: 'template_card',
            agentid: app.agent_id,
            template_card: card,
            enable_duplicate_check: 1,
            duplicate_check_interval: DUPLICATE_CHECK_INTERVAL.to_i
          )
        )
      rescue ::Gitlab::HTTP::BlockedUrlError => e
        raise PermanentError, "WeCom endpoint is not reachable: #{e.class}"
      rescue *::Gitlab::HTTP::HTTP_ERRORS => e
        raise TransientError, "WeCom request failed: #{e.class}"
      end

      def parse(response)
        check_status!(response)

        body = ::Gitlab::Json::SafeParser.parse(response.body)
        body = {} unless body.is_a?(Hash)

        errcode = body['errcode']
        raise PermanentError, 'WeCom returned no errcode' if errcode.nil?

        errcode = errcode.to_i
        return body if errcode == 0

        classify!(errcode, body['errmsg'])
      rescue ::JSON::ParserError
        raise TransientError, 'WeCom returned a malformed body'
      end

      def check_status!(response)
        return if response.success?

        if response.server_error? || RETRYABLE_HTTP_STATUS.include?(response.code.to_i)
          raise TransientError, "WeCom returned HTTP #{response.code}"
        end

        # 429 lands here on purpose. Without a wait derived from Retry-After,
        # retrying blind makes the throttling worse.
        raise PermanentError, "WeCom returned HTTP #{response.code}"
      end

      # Only codes known to be worth repeating are transient. Anything
      # unrecognised fails closed as permanent, so a new WeCom error can never
      # turn into a retry storm.
      def classify!(errcode, errmsg)
        raise TokenRejected if TOKEN_REJECTED_CODES.include?(errcode)

        raise TransientError, "WeCom is busy: errcode=#{errcode} errmsg=#{errmsg}" if errcode == SYSTEM_BUSY_CODE

        if errcode == RATE_LIMITED_CODE
          raise PermanentError, "WeCom rate limited the app: errcode=#{errcode} errmsg=#{errmsg}"
        end

        # A wrong agent id, a member outside the app's visible range, a revoked
        # permission. Retrying sends the same rejected request again.
        raise PermanentError, "WeCom refused the message: errcode=#{errcode} errmsg=#{errmsg}"
      end

      def split_recipients(value)
        value.to_s.split(RECIPIENT_SEPARATOR).reject(&:empty?)
      end
    end
  end
end
