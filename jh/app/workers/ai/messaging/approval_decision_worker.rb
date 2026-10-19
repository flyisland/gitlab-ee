# frozen_string_literal: true

module Ai
  module Messaging
    # Applies a decision made with an approval card button, on whichever chat
    # surface (Adapters::ChatAssistant) sent the card. The button callbacks
    # must be answered within seconds, which settling one card and opening the
    # next do not fit into, so they only check the click and enqueue this.
    class ApprovalDecisionWorker
      include ApplicationWorker

      data_consistency :sticky
      queue_namespace :ai_messaging
      feature_category :duo_agent_platform
      urgency :low
      worker_has_external_dependencies!
      # A second run finds the call answered and changes nothing.
      idempotent!
      # A run that died after rolling the card would roll it again.
      sidekiq_options retry: false

      # @param workflow_id [Integer] the session the card asked about
      # @param user_id [Integer] the GitLab user who clicked, the session's invoker
      # @param approved [Boolean] which button
      # @param fingerprint [String] the call the card was rendered for
      # @param card_id [String] the card clicked
      # @return [void]
      def perform(workflow_id, user_id, approved, fingerprint, card_id)
        workflow = ::Ai::DuoWorkflows::Workflow.find_by_id(workflow_id)
        user = ::User.find_by_id(user_id)
        return unless workflow && user

        context = workflow.messaging_callback_context || {}
        adapter_class = ::Ai::Messaging::AdapterRegistry[context['adapter']]
        return unless adapter_class && adapter_class <= ::Ai::Messaging::Adapters::ChatAssistant

        adapter = adapter_class.from_callback_context(context)

        ::Gitlab::I18n.with_user_locale(user) do
          result = ::Ai::Messaging::ApprovalDecisionService.new(
            workflow: workflow,
            current_user: user,
            adapter: adapter,
            approved: approved,
            fingerprint: fingerprint,
            note: adapter.decision_note(approved)
          ).execute

          # A decision still being made by a reply settles the card itself.
          next if result.success? || result.payload[:cause] == :decision_in_progress

          adapter.expire_approval_card(card_id, workflow, note: adapter.error_message(result.reason))
        end

        nil
      end
    end
  end
end
