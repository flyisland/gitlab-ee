# frozen_string_literal: true

module Ai
  module Messaging
    # Applies a chat robot user's decision, from a reply or a card button, on the
    # tool call their session is parked on. Both resolve through upstream's
    # ResolveToolApprovalService, so only one decision on a call goes through.
    class ApprovalDecisionService
      LEASE_TTL = 2.minutes
      # Answered as :approval_not_pending: the call is gone or being decided.
      STALE_REASONS = %i[not_approvable stale_request decision_in_progress].freeze
      FORBIDDEN_REASONS = %i[not_owner not_authorized forbidden].freeze

      # Whether fingerprint still names the call the session is waiting on.
      def self.pending?(workflow, fingerprint)
        fingerprint.present? &&
          workflow.tool_call_approval_required? &&
          ::Ai::DuoWorkflows::PendingToolApproval.for(workflow)&.fingerprint == fingerprint &&
          workflow.messaging_callback_context&.dig('answered_approval') != fingerprint
      end

      # note is what the settled request card says the decision did.
      def initialize(workflow:, current_user:, adapter:, approved:, fingerprint:, message: nil, note: nil)
        @workflow = workflow
        @current_user = current_user
        @adapter = adapter
        @approved = approved
        @fingerprint = fingerprint
        @message = message
        @note = note
      end

      # On success payload[:card_rolled] says whether the next turn has a card
      # of its own. Errors carry a reason the adapters have a text for, and the
      # upstream one as payload[:cause].
      def execute
        # A decision resumes a turn without the checks a new message runs, so a
        # revoked permission would otherwise still let the pending action run.
        return error(:forbidden) unless flow_authorized?

        with_lease { decide }
      end

      private

      attr_reader :workflow, :current_user, :adapter, :approved, :fingerprint, :message, :note

      # The card is rolled before the turn is resumed, so the turn never writes
      # into the request card; the lease and the check before it make sure the
      # decision that follows is the one that goes through.
      def decide
        reload_workflow
        return error(:stale_request) unless self.class.pending?(workflow, fingerprint)

        rolled = adapter.roll_card_for_decision(workflow: workflow, note: note)
        result = resolve
        return ServiceResponse.success(payload: { card_rolled: rolled }) if result.success?

        failure = error(result.reason)
        # Otherwise the card opened for the next turn would wait forever.
        adapter.deliver_error(callback_context: workflow.messaging_callback_context, error: failure.reason) if rolled

        failure
      end

      def resolve
        ::Ai::DuoWorkflows::ResolveToolApprovalService.new(
          workflow: workflow,
          current_user: current_user,
          approved: approved,
          fingerprint: fingerprint,
          message: message,
          surface: adapter.class.adapter_key
        ).execute
      end

      def flow_authorized?
        ::Ai::DuoWorkflows::FlowExecutionAuthorizer.for_background_caller(
          current_user: current_user,
          container: workflow.project,
          workflow_definition: workflow.workflow_definition,
          resolve_service_account: false
        ).execute.success?
      end

      def with_lease
        lease_key = "jh_ai_messaging_approval_decision:#{workflow.id}"
        uuid = Gitlab::ExclusiveLease.new(lease_key, timeout: LEASE_TTL.to_i).try_obtain
        return error(:decision_in_progress) unless uuid

        begin
          yield
        ensure
          Gitlab::ExclusiveLease.cancel(lease_key, uuid)
        end
      end

      def reload_workflow
        ::Gitlab::Database::LoadBalancing::SessionMap.current(workflow.load_balancer).use_primary do
          workflow.reload # rubocop:disable Cop/ActiveRecordAssociationReload -- the record, not an association
        end
      end

      def error(cause)
        reason = cause
        reason = :approval_not_pending if STALE_REASONS.include?(cause)
        reason = :forbidden if FORBIDDEN_REASONS.include?(cause)
        reason = :execute_workflow_failed unless %i[approval_not_pending forbidden].include?(reason)

        ServiceResponse.error(message: reason.to_s, reason: reason, payload: { cause: cause })
      end
    end
  end
end
