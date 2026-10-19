# frozen_string_literal: true

module Ai
  module Messaging
    # Turns an inbound DingTalk robot message into a Duo Agent Platform turn.
    # The returned text is the webhook's synchronous response.
    class DingtalkTriggerService < ChatTriggerService
      FLOW_REFERENCE = JH::Ai::Catalog::FoundationalFlow::DINGTALK_ASSISTANT_FLOW_REFERENCE

      DINGTALK_CONTEXT_PREAMBLE = <<~PREAMBLE.strip
        You received a message in a DingTalk conversation.
        The conversation below is oldest first. Earlier messages are background; respond to the last one.

        <formatting>
        Respond in standard Markdown. Always write links as [text](url); never
        put a bare URL inside bold, italic, or code formatting.
        </formatting>
        Your final response will automatically be posted back to the DingTalk conversation.
      PREAMBLE

      def initialize(user:, corp_id:, conversation_id:, conversation_type:, sender_staff_id:, message:)
        super(user: user, message: message)

        @corp_id = corp_id
        @conversation_id = conversation_id
        @conversation_type = conversation_type
        @sender_staff_id = sender_staff_id
      end

      private

      attr_reader :corp_id, :conversation_id, :conversation_type, :sender_staff_id

      def adapter
        @adapter ||= Adapters::Dingtalk.new(
          corp_id: corp_id,
          conversation_id: conversation_id,
          conversation_type: conversation_type,
          sender_staff_id: sender_staff_id,
          turn_token: turn_token
        )
      end

      # DingTalk offers no way to start a fresh conversation: openThreadId repeats
      # conversationId in both single and group chats, so the history is the only
      # thing /new can clear.
      def session_store
        @session_store ||= ::Gitlab::Dingtalk::DuoSessionStore.new(
          corp_id: corp_id,
          conversation_id: conversation_id,
          sender_staff_id: sender_staff_id,
          user_id: user.id
        )
      end

      def flow_reference
        FLOW_REFERENCE
      end

      def source_type
        :dingtalk
      end

      def context_preamble
        DINGTALK_CONTEXT_PREAMBLE
      end

      def rate_limit_key
        :dingtalk_duo_chat
      end

      def cancelled_message(with_feedback:)
        if with_feedback
          s_('JH|DuoDingtalk|Cancelled that action and passed your message on to Duo.')
        else
          s_('JH|DuoDingtalk|Cancelled that action.')
        end
      end

      def acknowledgement_message
        s_('JH|DuoDingtalk|Duo is working on it…')
      end

      def reset_confirmation_message
        s_('JH|DuoDingtalk|Cleared the conversation. Your next message starts a new session.')
      end

      def rate_limited_message
        s_('JH|DuoDingtalk|You are sending messages too quickly. Wait a moment and try again.')
      end
    end
  end
end
