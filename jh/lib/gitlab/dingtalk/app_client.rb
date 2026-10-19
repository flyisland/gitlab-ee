# frozen_string_literal: true

module Gitlab
  module Dingtalk
    class AppClient
      ENDPOINT = 'https://oapi.dingtalk.com/topapi/message/corpconversation/asyncsend_v2'
      TransientError = AppResponse::TransientError
      PermanentError = AppResponse::PermanentError

      def initialize(app: ::Gitlab::Dingtalk::App)
        @app = app
      end

      def send_card(user_id, card)
        raise ArgumentError, 'invalid recipient' unless Recipient.valid_user_id?(user_id)

        deliver(user_id, card)
      end

      private

      attr_reader :app

      def deliver(user_id, card, retried: false)
        response = ::Gitlab::HTTP.post(
          ENDPOINT,
          query: { access_token: app.access_token },
          headers: { 'Content-Type' => 'application/json' },
          body: ::Gitlab::Json.generate(
            agent_id: app.agent_id.to_i, userid_list: user_id, to_all_user: false,
            msg: { msgtype: 'action_card', action_card: card }
          )
        )
        AppResponse.parse(response)
      rescue AppResponse::TokenRejected
        raise TransientError, 'DingTalk kept rejecting the access token', cause: nil if retried

        app.invalidate_access_token
        deliver(user_id, card, retried: true)
      rescue ::Gitlab::HTTP::BlockedUrlError
        raise PermanentError, 'DingTalk endpoint is blocked', cause: nil
      rescue *::Gitlab::HTTP::HTTP_ERRORS
        raise TransientError, 'DingTalk message request failed', cause: nil
      end
    end
  end
end
