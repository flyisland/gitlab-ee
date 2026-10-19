# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class Run < Presenters::Base
        def present(pipeline)
          build = pipeline.builds.take # rubocop: disable CodeReuse/ActiveRecord
          responder = Chat::Responder.responder_for(build)

          if build && responder
            responder.scheduled_output
          else
            unsupported_chat_service
          end
        end

        def unsupported_chat_service
          {
            type: :text,
            content: s_('JH|Chatops|Sorry, this chat service is currently not supported by JiHu GitLab ChatOps.')
          }
        end

        def failed_to_schedule(command)
          {
            type: :text,
            content: ::Kernel.format(s_('JH|Chatops|The command could not be scheduled. Please confirm ' \
              'the ".gitlab-ci.yml" file defines a job with the name %{command}.'),
              command: command)
          }
        end
      end
    end
  end
end
