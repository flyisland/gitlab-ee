# frozen_string_literal: true

module Gitlab
  module Feishu
    class AppClient
      MESSAGE_PATH = '/open-apis/im/v1/messages'
      IMAGE_PATH = '/open-apis/im/v1/images'
      TransientError = AppResponse::TransientError
      PermanentError = AppResponse::PermanentError

      def initialize(app: App)
        @app = app
      end

      def send_card(open_id, card, uuid:)
        with_token_retry { post_message(open_id, card, uuid) }
      end

      def upload_image(file_path)
        with_token_retry { File.open(file_path, 'rb') { |file| post_image(file) } }
      end

      private

      attr_reader :app

      def with_token_retry
        retried = false
        begin
          AppResponse.parse(yield)
        rescue AppResponse::TokenRejected
          raise TransientError, 'Feishu kept rejecting the access token' if retried

          retried = true
          app.invalidate_access_token
          retry
        end
      end

      def post_message(open_id, card, uuid)
        post(
          MESSAGE_PATH,
          query: { receive_id_type: 'open_id' },
          headers: { 'Content-Type' => 'application/json' },
          body: ::Gitlab::Json.generate(
            receive_id: open_id, msg_type: 'interactive', content: ::Gitlab::Json.generate(card), uuid: uuid
          )
        )
      end

      def post_image(file)
        post(IMAGE_PATH, body: { image_type: 'message', image: file }, multipart: true)
      end

      def post(path, headers: {}, **options)
        ::Gitlab::HTTP.post(
          "#{app.api_site}#{path}",
          headers: headers.merge('Authorization' => "Bearer #{app.access_token}"),
          timeout: 10, follow_redirects: false, **options
        )
      rescue ::Gitlab::HTTP::BlockedUrlError
        raise PermanentError, 'Feishu endpoint is blocked'
      rescue *::Gitlab::HTTP::HTTP_ERRORS
        raise TransientError, 'Feishu request failed'
      end
    end
  end
end
