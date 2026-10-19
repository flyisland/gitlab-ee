# frozen_string_literal: true

module Ai
  module Messaging
    # Turns an inbound Feishu robot message into a Duo Agent Platform turn.
    # Runs in Feishu::DuoMessageWorker, after the event callback has returned;
    # the worker posts the returned text as a reply to the message.
    class FeishuTriggerService < ChatTriggerService
      FLOW_REFERENCE = JH::Ai::Catalog::FoundationalFlow::FEISHU_ASSISTANT_FLOW_REFERENCE

      FEISHU_CONTEXT_PREAMBLE = <<~PREAMBLE.strip
        You received a message in a Feishu conversation.
        The conversation below is oldest first. Earlier messages are background; respond to the last one.

        <formatting>
        Respond in standard Markdown. Always write links as [text](url); never
        put a bare URL inside bold, italic, or code formatting.
        </formatting>
        Your final response will automatically be posted back to the Feishu conversation.
      PREAMBLE

      # sender_id is the Feishu user ID the ChatOps account binding is keyed by.
      def initialize(user:, app_id:, chat_id:, sender_id:, message_id:, message:, thread_id: nil)
        super(user: user, message: message)

        @app_id = app_id
        @chat_id = chat_id
        @thread_id = thread_id
        @sender_id = sender_id
        @message_id = message_id
      end

      private

      attr_reader :app_id, :chat_id, :thread_id, :sender_id, :message_id

      def adapter
        @adapter ||= Adapters::Feishu.new(
          app_id: app_id,
          chat_id: chat_id,
          thread_id: thread_id,
          sender_id: sender_id,
          message_id: message_id,
          turn_token: turn_token
        )
      end

      def session_store
        @session_store ||= ::Gitlab::Feishu::DuoSessionStore.new(
          app_id: app_id,
          chat_id: chat_id,
          thread_id: thread_id,
          sender_id: sender_id,
          user_id: user.id
        )
      end

      def flow_reference
        FLOW_REFERENCE
      end

      def source_type
        :feishu
      end

      def context_preamble
        FEISHU_CONTEXT_PREAMBLE
      end

      def rate_limit_key
        :feishu_duo_chat
      end

      def cancelled_message(with_feedback:)
        if with_feedback
          s_('JH|DuoFeishu|Cancelled that action and passed your message on to Duo.')
        else
          s_('JH|DuoFeishu|Cancelled that action.')
        end
      end

      def acknowledgement_message
        s_('JH|DuoFeishu|Duo is working on it…')
      end

      def reset_confirmation_message
        s_('JH|DuoFeishu|Cleared the conversation. Your next message starts a new session.')
      end

      def rate_limited_message
        s_('JH|DuoFeishu|You are sending messages too quickly. Wait a moment and try again.')
      end
    end
  end
end
