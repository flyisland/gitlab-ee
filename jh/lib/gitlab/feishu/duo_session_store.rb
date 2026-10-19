# frozen_string_literal: true

module Gitlab
  module Feishu
    # The Duo session and history of one Feishu conversation participant. A
    # topic (thread) in a group is a conversation of its own.
    class DuoSessionStore < ::Ai::Messaging::ChatSessionStore
      def initialize(app_id:, chat_id:, sender_id:, user_id:, thread_id: nil)
        @app_id = app_id
        @chat_id = chat_id
        @thread_id = thread_id
        @sender_id = sender_id
        @user_id = user_id
      end

      private

      attr_reader :app_id, :chat_id, :thread_id, :sender_id, :user_id

      def key_for(name)
        "feishu:duo:{#{app_id}:#{chat_id}:#{thread_id}:#{sender_id}:#{user_id}}:#{name}"
      end
    end
  end
end
