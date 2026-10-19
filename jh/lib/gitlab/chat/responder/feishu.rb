# frozen_string_literal: true

module Gitlab
  module Chat
    module Responder
      class Feishu < Responder::Base
        SUCCESS_TITLE = "ChatOps job finished"
        FAILURE_TITLE = "ChatOps job failed"

        def send_response(message_title, message_content)
          response_body = response_body(message_title, message_content)

          http_client.send_message(Gitlab::Json.generate(response_body), type: nil)
        end

        def success(_output)
          message_content = <<~MESSAGE_CONTENT
            ### ChatOps job #{build_ref} started by #{user_ref} completed successfully
            ID: #{build_ref}
            Name: #{build.name}
          MESSAGE_CONTENT

          send_response(SUCCESS_TITLE, message_content)
        end

        # Sends the output for a build that failed.
        def failure
          message_content = <<~CONTENT
            ### ChatOps job #{build_ref} started by #{user_ref} failed!
            ID: #{build_ref}
            Name: #{build.name}
          CONTENT

          send_response(FAILURE_TITLE, message_content)
        end

        # Returns the output to send back after a command has been scheduled.
        def scheduled_output
          {
            type: :markdown,
            title: "Job created",
            content: "Your ChatOps job #{build_ref} has been created!"
          }
        end

        private

        def response_body(message_title, message_content)
          {
            receive_id: receive_id,
            msg_type: :interactive,
            content: Gitlab::Json.generate({
              header: {
                title: {
                  tag: "plain_text",
                  content: message_title
                }
              },
              elements: [
                { tag: "markdown", content: message_content }
              ]
            })
          }
        end

        def user_ref
          user = pipeline.chat_data.chat_name.user
          user_url = ::Gitlab::Routing.url_helpers.user_url(user)
          "[#{user.name}](#{user_url})"
        end

        def build_ref
          build_url = ::Gitlab::Routing.url_helpers.project_build_url(project, build)
          "[##{build.id}](#{build_url})"
        end

        def receive_id
          pipeline.variables.find { |var| var.key == "CHAT_CHANNEL" }.value
        end

        def http_client
          @http_client ||= Gitlab::Feishu::Client.build
        end
      end
    end
  end
end
