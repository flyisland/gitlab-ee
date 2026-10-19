# frozen_string_literal: true

module Ai
  module Messaging
    module Adapters
      # Behavior shared by the chat robot adapters (DingTalk, Feishu): each runs
      # its own foundational flow on Workhorse, streams one turn into a card, and
      # asks the invoker to approve writes by replying in the conversation.
      #
      # Including adapters implement #card_opened?, #roll_card_for_decision,
      # #error_message, #assistant_flow, #approval_text,
      # #deliver_approval_request_to_chat and #track_delivery_exception, and for
      # approval buttons (ApprovalDecisionWorker) #decision_note and
      # #expire_approval_card.
      module ChatAssistant
        MONOLOGUE_MAX_LENGTH = 1500
        # Privileges the flow declares but must not run unattended: each call
        # waits for the invoker's decision instead.
        UNAPPROVED_PRIVILEGES = [
          ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
          ::Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
        ].freeze
        # Outlives any realistic wait for a decision without keeping the claim
        # for the life of the session, which the flow may never reach the end of.
        APPROVAL_NOTICE_TTL = 1.day

        # Handed to a worker rather than sent here: the request this notice
        # describes may not be in a checkpoint yet (see ApprovalNoticeWorker).
        def on_approval_required(callback_context:, workflow:) # rubocop:disable Lint/UnusedMethodArgument -- the worker rebuilds the context from the workflow
          ::Ai::Messaging::ApprovalNoticeWorker.perform_async(workflow.id)
        end

        # Asks the invoker to decide on the action the flow stopped for. The
        # answer comes back as their next message, which the trigger service
        # reads as a decision rather than as the next thing to work on.
        #
        # Returns false while the pending call has yet to reach a checkpoint, so
        # the worker knows to look again. The call's id claims the send, so the
        # at-least-once event cannot ask the same question twice; a failed send
        # releases the claim rather than leaving the user waiting in silence.
        def deliver_approval_request(callback_context:, workflow:)
          pending = pending_tool_call(workflow)
          return false unless pending
          # Not "already sent": the log is cumulative, so a claim already held
          # means the newest request in it is one the user answered and the real
          # one has yet to land. Returning false is what makes the worker retry.
          return false unless claim_approval_notice(workflow, pending)

          delivered = deliver_approval_request_to_chat(
            callback_context, pending, workflow, notice_key: approval_notice_key(workflow, pending)
          )
          release_approval_notice(workflow, pending) unless delivered

          delivered
        rescue StandardError => e
          release_approval_notice(workflow, pending) if pending
          track_delivery_exception(e, callback_context)
          false
        end

        private

        # Upstream names the Slack flow here, so a chat turn would run with
        # Slack's privileges and environment. Overridden to use the surface's own
        # flow, and to keep the privileges that need a decision out of the
        # pre-approved list: a pre-approved privilege never reaches the approval
        # path, and these surfaces have one (ChatTriggerService,
        # ApprovalDecisionService).
        def start_workhorse_flow(bundle, ctx)
          flow = assistant_flow

          ::Ai::DuoWorkflows::CreateWorkflowService.new(
            container: bundle.container,
            current_user: bundle.current_user,
            params: {
              goal: bundle.goal,
              workflow_definition: bundle.flow_reference,
              agent_privileges: flow.agent_privileges,
              pre_approved_agent_privileges: flow.agent_privileges - UNAPPROVED_PRIVILEGES,
              allow_agent_to_request_user: flow.allow_agent_to_request_user,
              environment: flow.environment,
              messaging_callback_context: enriched_callback_context(ctx, bundle),
              source_type: bundle.source_type,
              source_link: bundle.source_link,
              **resource_params(bundle.resource)
            }.compact
          ).execute
        end

        def latest_monologue(turn)
          turn.reverse_each
            .detect { |entry| entry['message_type'] == 'agent' && entry['content'].present? }
            &.dig('content')
            &.truncate(MONOLOGUE_MAX_LENGTH, separator: ' ')
        end

        # The snapshot covers the whole session, not this turn: a turn is what
        # follows the message that started it. Without this the card replays
        # every earlier answer above the one being written.
        def current_turn(messages)
          started_at = messages.rindex { |entry| entry['message_type'] == 'user' }
          return messages unless started_at

          messages[(started_at + 1)..] || []
        end

        # The approval request the flow is parked on. The node that writes it
        # marks it as a request and attaches the call, which is what separates
        # it from the prompt asking for the next message.
        def pending_tool_call(workflow)
          (workflow.latest_ui_chat_log || []).reverse.find { |entry| approval_request?(entry) }
        end

        # A request that names a call is one waiting to be approved; the prompt
        # asking for the next message is a request with no call attached.
        def approval_request?(entry)
          entry['message_type'] == 'request' && entry['tool_info'].present?
        end

        def pending_approval?(messages)
          approval_request?(messages.last || {})
        end

        def claim_approval_notice(workflow, pending)
          Gitlab::Redis::SharedState.with do |redis|
            redis.set(approval_notice_key(workflow, pending), 1, ex: APPROVAL_NOTICE_TTL, nx: true)
          end
        end

        def release_approval_notice(workflow, pending)
          Gitlab::Redis::SharedState.with { |redis| redis.del(approval_notice_key(workflow, pending)) }
        end

        def approval_notice_key(workflow, pending)
          "#{self.class.adapter_key}:duo_approval_notice:#{workflow.id}:" \
            "#{pending['message_id'] || pending['timestamp']}"
        end
      end
    end
  end
end
