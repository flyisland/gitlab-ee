# frozen_string_literal: true

module Ai
  module Messaging
    # Turns an inbound chat robot message into a Duo Agent Platform turn.
    # Every message starts a new session that finishes when the turn ends, like
    # Slack; the invoker's recent exchanges ride along in the goal. A reply to a
    # pending approval is the exception: it decides that session instead. Returns
    # the text to answer the message with; nil means the user was already
    # answered asynchronously (e.g. a delivered error).
    #
    # Subclasses supply the surface: its adapter, session store, flow and texts.
    class ChatTriggerService
      include ::Gitlab::Utils::StrongMemoize

      # Slash-prefixed only: the bare Chinese word for "reset" is a plausible
      # answer to a question the agent just asked, and eating it would drop the
      # turn and the context.
      RESET_COMMANDS = ['/new', '/reset'].freeze

      # A session parked on a tool call is waiting for a decision rather than a
      # message. Only an exact match approves; every other reply is a rejection
      # carrying the user's own words, so a reply this list does not know can
      # never run the action. Traditional and simplified forms both appear
      # because the surface is read in both, and the near-misses of the word the
      # prompt asks for are listed because people type what they mean, not what
      # was asked: "approval" read as a refusal is the confusing failure here,
      # not a dangerous one.
      APPROVE_COMMANDS = %w[/approve approve approval approved ok 同意 批准 确认 確認].freeze
      REJECT_COMMANDS = %w[/reject reject 拒绝 拒絕 取消].freeze

      def initialize(user:, message:)
        @user = user
        @message = message
      end

      def execute
        return rate_limited_message if throttled?
        return reset_session_message if reset_requested?

        # Asked before the value is read: a decision can legitimately answer with
        # nothing, which is not the same as this message not being one.
        return approval_decision_message if awaiting_decision?

        # One turn at a time per invoker: a second session started now would miss
        # the answer still being written, and its card would land out of order.
        # The lock covers the gap until the new session is stored; from then on
        # its status does.
        lock = session_store.lock_turn!
        return sync_error_message(:workflow_locked) unless lock

        begin
          clear_memoization(:session_workflow)
          return sync_error_message(:workflow_locked) if turn_in_progress?

          start_turn
        ensure
          session_store.unlock_turn!(lock)
        end
      end

      private

      attr_reader :user, :message, :turn_token

      def start_turn
        goal = build_goal
        return sync_error_message(:message_too_long) unless goal

        # Pre-flight failures are answered with the returned text instead of a
        # delivery of their own: the caller is about to answer the message anyway.
        resolution = new_session_bundle(goal)
        return sync_error_message(resolution.reason) if resolution.error?

        # Opened before the flow is triggered: the turn is enqueued inside trigger
        # and can deliver its answer before this method gets the workflow back, so
        # the token the answer is matched against has to exist by then.
        @turn_token = session_store.start_turn!(message)

        result = adapter.trigger(resolution.payload[:bundle])
        return unless result.success?

        store_session(result.payload[:workflow])
        # The card already says the turn is running, and it is the bubble the
        # answer grows in; a separate acknowledgement would only be a line the
        # user watches go stale.
        return if adapter.card_opened?

        acknowledgement_message
      end

      # The adapter for this message. Built after the turn opens when a turn
      # starts, so it carries #turn_token into the callback context.
      def adapter
        raise Gitlab::AbstractMethodError
      end

      # The ChatSessionStore for this invoker in this conversation.
      def session_store
        raise Gitlab::AbstractMethodError
      end

      def flow_reference
        raise Gitlab::AbstractMethodError
      end

      def source_type
        raise Gitlab::AbstractMethodError
      end

      # Instructions that open the goal, ahead of the conversation itself.
      def context_preamble
        raise Gitlab::AbstractMethodError
      end

      # A Gitlab::ApplicationRateLimiter key scoped by user.
      def rate_limit_key
        raise Gitlab::AbstractMethodError
      end

      def acknowledgement_message
        raise Gitlab::AbstractMethodError
      end

      def reset_confirmation_message
        raise Gitlab::AbstractMethodError
      end

      def rate_limited_message
        raise Gitlab::AbstractMethodError
      end

      # What a refusal did, with or without feedback passed on to the agent.
      def cancelled_message(with_feedback:) # rubocop:disable Lint/UnusedMethodArgument -- abstract method defines the contract for subclasses
        raise Gitlab::AbstractMethodError
      end

      def session_workflow
        workflow_id = session_store.current_workflow_id
        return unless workflow_id

        workflow = ::Ai::DuoWorkflows::Workflow.find_by_id(workflow_id)
        return unless workflow
        return unless workflow.user_id == user.id
        # Partition retention drops the checkpoints at 30 days, but every turn
        # refreshes the store's TTL, so a daily conversation outlives its own
        # history. Past that the pointer has to be abandoned.
        return if workflow.archived?

        workflow
      end
      strong_memoize_attr :session_workflow

      def awaiting_decision?
        session_workflow&.awaiting_approval?
      end

      # Created counts too: a turn waiting for its worker has not started running yet.
      def turn_in_progress?
        %i[created running].include?(session_workflow&.status_name)
      end

      # Answers a message that is a decision on a pending tool call. The session
      # keeps waiting when the decision is refused, so the user can answer again.
      # A reply answers whatever call is pending now, so its fingerprint is read
      # here; a card button carries the one it was rendered for.
      def approval_decision_message
        workflow = session_workflow
        outcome = decision_outcome

        result = ::Ai::Messaging::ApprovalDecisionService.new(
          workflow: workflow,
          current_user: user,
          adapter: adapter,
          approved: approved?,
          fingerprint: ::Ai::DuoWorkflows::PendingToolApproval.for(workflow)&.fingerprint,
          message: rejection_message,
          # What the settled card says, while the reply below stays as it was.
          note: approved? ? adapter.decision_note(true) : outcome
        ).execute
        return sync_error_message(result.reason) if result.error?
        return if result.payload[:card_rolled]

        outcome || acknowledgement_message
      end

      # What the decision did, for a refusal. An approval needs no line of its
      # own: the action it approved is on the card above it.
      def decision_outcome
        return if approved?

        cancelled_message(with_feedback: rejection_message.present?)
      end

      def approved?
        APPROVE_COMMANDS.include?(normalized_message)
      end

      # An explicit rejection cancels the call and says nothing; anything else
      # is feedback the agent reads before it tries again.
      def rejection_message
        return if approved? || REJECT_COMMANDS.include?(normalized_message)

        message.to_s.strip
      end

      def normalized_message
        message.to_s.strip.downcase
      end

      def new_session_bundle(goal)
        resolved = ::Ai::Messaging::DefaultProjectFlowResolver.new(
          flow_reference: flow_reference, current_user: user
        ).execute
        return resolved unless resolved.success?

        project = resolved.payload[:project]
        refusal = authorization_refusal(project)
        return refusal if refusal

        bundle_response(
          Adapters::Base::TriggerBundle.new(
            current_user: user,
            service_account: resolved.payload[:service_account],
            flow_reference: flow_reference,
            flow_config_id: resolved.payload[:flow_config_id],
            flow_config_schema_version: resolved.payload[:flow_config_schema_version],
            flow_version: resolved.payload[:flow_version],
            project: project,
            goal: goal,
            source_type: source_type
          )
        )
      end

      # Returns a ServiceResponse when the user may not run the flow, nil otherwise.
      def authorization_refusal(project)
        result = ::Ai::DuoWorkflows::FlowExecutionAuthorizer.for_background_caller(
          current_user: user,
          container: project,
          workflow_definition: flow_reference,
          resolve_service_account: false
        ).execute
        return if result.success?

        ServiceResponse.error(message: result.message, reason: :forbidden)
      end

      def bundle_response(bundle)
        ServiceResponse.success(payload: { bundle: bundle })
      end

      # Nil when the new message alone does not fit; older exchanges are dropped
      # first when the history does not.
      def build_goal
        entries = session_store.transcript + [{ 'role' => 'user', 'text' => message.to_s }]
        conversation = ::Ai::Messaging::Conversation.new(
          messages: entries.map { |entry| render_message(entry) },
          marker: method(:omitted_marker)
        )

        goal, = conversation.render_within(::Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH) do |block|
          "#{context_preamble}\n\n<conversation>\n#{block}\n</conversation>"
        end

        goal
      end

      def render_message(entry)
        role = entry['role'] == 'assistant' ? 'assistant' : 'user'

        "<message role=\"#{role}\">\n#{CGI.escapeHTML(entry['text'].to_s)}\n</message>"
      end

      def omitted_marker(count)
        return if count == 0

        "<!-- #{count} earlier #{'message'.pluralize(count)} omitted due to length -->"
      end

      def sync_error_message(reason)
        adapter.error_message(reason || :execute_workflow_failed)
      end

      def store_session(workflow)
        session_store.store!(workflow.id) if workflow
      end

      def reset_requested?
        RESET_COMMANDS.include?(normalized_message)
      end

      def reset_session_message
        session_store.clear!
        reset_confirmation_message
      end

      def throttled?
        ::Gitlab::ApplicationRateLimiter.throttled?(rate_limit_key, scope: { user: user })
      end
    end
  end
end
