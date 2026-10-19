# frozen_string_literal: true

module Ai
  module Messaging
    # Per chat conversation participant: the latest Duo workflow session, so a
    # reply can answer a pending approval, and the recent exchanges, so the next
    # session starts with the conversation so far. Keyed per sender, not per
    # conversation: in a group chat each invoker keeps a history of their own.
    # Subclasses build the keys; the GitLab user is part of every key, so
    # re-binding a chat account to another user starts that user with no history.
    class ChatSessionStore
      TTL = 1.day
      # Messages, not exchanges. Together they stay within Workflow::GOAL_MAX_LENGTH,
      # so nothing is kept that the goal would drop anyway.
      TRANSCRIPT_LIMIT = 16
      ENTRY_MAX_LENGTH = 4_000

      # Appends only while the turn that produced the answer is still the one the
      # conversation is on. Compare and append in one script: between a separate
      # read and write, /new can empty the history and the answer would land in it.
      RECORD_ANSWER_SCRIPT = ::Labkit::Redis::Script.new(<<~LUA)
        if redis.call("get", KEYS[1]) ~= ARGV[1] then
          return 0
        end

        redis.call("rpush", KEYS[2], ARGV[2])
        redis.call("ltrim", KEYS[2], -tonumber(ARGV[3]), -1)
        redis.call("expire", KEYS[2], tonumber(ARGV[4]))

        return 1
      LUA

      # Outlasts resolving and triggering a turn; past it, a stuck holder stops blocking the conversation.
      TURN_LOCK_TTL = 1.minute
      UNLOCK_SCRIPT = ::Labkit::Redis::Script.new(<<~LUA)
        if redis.call("get", KEYS[1]) == ARGV[1] then
          return redis.call("del", KEYS[1])
        end

        return 0
      LUA

      # Returns the token to unlock with, or nil when another message holds the lock.
      def lock_turn!
        token = SecureRandom.hex(8)
        locked = Gitlab::Redis::SharedState.with do |redis|
          redis.set(lock_key, token, nx: true, ex: TURN_LOCK_TTL)
        end

        token if locked
      end

      def unlock_turn!(token)
        Gitlab::Redis::SharedState.with do |redis|
          UNLOCK_SCRIPT.eval(redis, keys: [lock_key], argv: [token])
        end
      end

      def current_workflow_id
        Gitlab::Redis::SharedState.with { |redis| redis.get(session_key) }&.to_i
      end

      def store!(workflow_id)
        Gitlab::Redis::SharedState.with { |redis| redis.set(session_key, workflow_id, ex: TTL) }
      end

      # Opens a turn: records the message and returns the token that marks it as
      # the current one. Written before the flow is triggered, because the turn can
      # answer before the caller gets a workflow id back.
      def start_turn!(text)
        token = SecureRandom.hex(8)
        entry = encode('user', text)

        Gitlab::Redis::SharedState.with do |redis|
          redis.multi do |transaction|
            transaction.set(turn_key, token, ex: TTL)
            next if entry.nil?

            transaction.rpush(transcript_key, entry)
            transaction.ltrim(transcript_key, -TRANSCRIPT_LIMIT, -1)
            transaction.expire(transcript_key, TTL)
          end
        end

        token
      end

      # Returns whether the answer was recorded: a token that no longer matches
      # belongs to a turn the conversation has moved past or reset.
      def record_answer!(token, text)
        entry = encode('assistant', text)
        return false if token.blank? || entry.nil?

        result = Gitlab::Redis::SharedState.with do |redis|
          RECORD_ANSWER_SCRIPT.eval(
            redis,
            keys: [turn_key, transcript_key],
            argv: [token, entry, TRANSCRIPT_LIMIT, TTL.to_i]
          )
        end

        result.to_i == 1
      end

      # Oldest first, as [{ 'role' => 'user' | 'assistant', 'text' => String }].
      def transcript
        entries = Gitlab::Redis::SharedState.with { |redis| redis.lrange(transcript_key, 0, -1) }

        entries.filter_map do |entry|
          parsed = Gitlab::Json.parse(entry)
          parsed if parsed.is_a?(Hash)
        rescue JSON::ParserError
          nil
        end
      end

      # Drops the pointer, the history and the open turn, so an answer still on its
      # way cannot land in the conversation the user just cleared. The workflows
      # stay readable in GitLab.
      def clear!
        Gitlab::Redis::SharedState.with { |redis| redis.del(session_key, transcript_key, turn_key) }
      end

      private

      def encode(role, text)
        return if text.blank?

        Gitlab::Json.dump({ 'role' => role, 'text' => text.truncate(ENTRY_MAX_LENGTH) })
      end

      # Every key of one participant must share a Redis Cluster hash tag, which
      # multi-key commands and the script above both need.
      def key_for(_name)
        raise Gitlab::AbstractMethodError
      end

      def session_key
        @session_key ||= key_for('session')
      end

      def transcript_key
        @transcript_key ||= key_for('transcript')
      end

      def turn_key
        @turn_key ||= key_for('turn')
      end

      def lock_key
        @lock_key ||= key_for('lock')
      end
    end
  end
end
