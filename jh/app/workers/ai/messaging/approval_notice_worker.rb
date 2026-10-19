# frozen_string_literal: true

module Ai
  module Messaging
    # Asks the invoker to decide on the tool call their chat Duo session stopped
    # for, on whichever chat surface (Adapters::ChatAssistant) started it.
    #
    # Separate from the event that schedules it because the Duo Workflow Service
    # flips the workflow's status before it writes the checkpoint carrying the
    # request: CallbackWorker can therefore run while the pending call is still
    # milliseconds away, and a notice that cannot name the action it is asking
    # about is worse than one that arrives a moment later.
    class ApprovalNoticeWorker
      include ApplicationWorker

      data_consistency :delayed
      queue_namespace :ai_messaging
      feature_category :duo_agent_platform
      urgency :low
      worker_has_external_dependencies!
      # Sending twice is prevented by the adapter's own claim rather than by
      # deduplication, which a rescheduled attempt would not cover anyway.
      idempotent!

      RETRY_IN = 2.seconds
      MAX_ATTEMPTS = 5

      def perform(workflow_id, attempt = 1)
        workflow = ::Ai::DuoWorkflows::Workflow.find_by_id(workflow_id)
        # Decided already (or never waiting): the session has moved on and the
        # request this notice would describe is no longer the one in front of the user.
        return unless workflow&.awaiting_approval?

        callback_context = workflow.messaging_callback_context
        adapter_class = ::Ai::Messaging::AdapterRegistry[callback_context&.dig('adapter')]
        return unless adapter_class && adapter_class <= ::Ai::Messaging::Adapters::ChatAssistant

        adapter = adapter_class.from_callback_context(callback_context)
        return if adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)
        return if attempt >= MAX_ATTEMPTS

        self.class.perform_in(RETRY_IN, workflow_id, attempt + 1)
      end
    end
  end
end
