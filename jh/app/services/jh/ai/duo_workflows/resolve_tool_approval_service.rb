# frozen_string_literal: true

module JH
  module Ai
    module DuoWorkflows
      # Chat robots read any reply that is not an approval as a rejection
      # carrying the user's words, which the agent answers. RunEvent already
      # takes that message; upstream's service just has no way to pass it.
      module ResolveToolApprovalService
        extend ::Gitlab::Utils::Override

        def initialize(message: nil, **kwargs)
          @message = message.presence
          super(**kwargs)
        end

        private

        attr_reader :message

        # Mirrors upstream #continue with the message added to the event.
        override :continue
        def continue
          return super if approved || message.nil?

          tool_names = ::Ai::DuoWorkflows::PendingToolApproval.for(workflow).tool_names

          result = ::Ai::DuoWorkflows::ExecuteRunService.new(
            workflow,
            event: { type: :approval, approved: false, message: message }
          ).execute

          return error(result.message, :continue_failed) if result.error?

          if workflow.messaging_callback_context.present?
            workflow.merge_messaging_callback_context!('answered_approval' => fingerprint)
          end

          audit_decision(tool_names)

          result
        end
      end
    end
  end
end
