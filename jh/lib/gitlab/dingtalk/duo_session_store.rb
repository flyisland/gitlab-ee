# frozen_string_literal: true

module Gitlab
  module Dingtalk
    # The Duo session and history of one DingTalk conversation participant.
    class DuoSessionStore < ::Ai::Messaging::ChatSessionStore
      def initialize(corp_id:, conversation_id:, sender_staff_id:, user_id:)
        @corp_id = corp_id
        @conversation_id = conversation_id
        @sender_staff_id = sender_staff_id
        @user_id = user_id
      end

      private

      attr_reader :corp_id, :conversation_id, :sender_staff_id, :user_id

      def key_for(name)
        "dingtalk:duo:{#{corp_id}:#{conversation_id}:#{sender_staff_id}:#{user_id}}:#{name}"
      end
    end
  end
end
