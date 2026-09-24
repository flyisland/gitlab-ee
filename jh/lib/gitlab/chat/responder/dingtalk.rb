# frozen_string_literal: true

module Gitlab
  module Chat
    module Responder
      class Dingtalk < Responder::Base
        def send_response(body)
          Gitlab::HTTP.post(
            pipeline.chat_data.response_url,
            {
              headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
              body: Gitlab::Json.generate(body)
            }
          )
        end

        def success(output)
          return if output.empty?

          body = {
            msgtype: :markdown,
            markdown: Gitlab::Json.generate({
              title: "ChatOps job finished",
              text: <<~CONTENT
                ### ChatOps job #{build_ref} started by #{user_ref} completed successfully\n
                ID: #{build_ref}\n
                Name: #{build.name}\n
              CONTENT
            })
          }

          send_response(body)
        end

        # Sends the output for a build that failed.
        def failure
          body = {
            msgtype: :markdown,
            markdown: Gitlab::Json.generate({
              title: "ChatOps job failed",
              text: <<~CONTENT
                ### ChatOps job #{build_ref} started by #{user_ref} failed!\n
                ID: #{build_ref}\n
                Name: #{build.name}\n
              CONTENT
            })
          }

          send_response(body)
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

        def data
          @data ||= ::Gitlab::Json.parse(pipeline.chat_data.response_url)
        end

        def target_info
          data['group_message'] ? { openConversationId: data['conversationId'] } : { userIds: [data['senderStaffId']] }
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

        def dingtalk_client
          ::Gitlab::Dingtalk::Client.new({
            corpid: ::Gitlab::CurrentSettings.dingtalk_corpid,
            app_secret: ::Gitlab::CurrentSettings.dingtalk_app_secret,
            app_key: ::Gitlab::CurrentSettings.dingtalk_app_key
          })
        end
      end
    end
  end
end
