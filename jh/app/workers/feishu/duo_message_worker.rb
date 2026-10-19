# frozen_string_literal: true

module Feishu
  # Runs one Feishu robot message as a Duo Agent Platform turn and replies to it.
  # Feishu re-pushes an event it did not see answered within three seconds, so
  # the callback only enqueues this and returns.
  #
  # At most one turn per message: the turn is claimed before it starts, and a
  # retry of a job that died after the claim gives up rather than start the
  # request again (which could repeat a write). The reply text is recorded
  # before it is sent, so a retry after a failed send only sends it again --
  # under the same uuid, which Feishu answers at most once an hour -- and a
  # sent reply is recorded too, so a push of the same message later on is
  # dropped.
  class DuoMessageWorker
    include ApplicationWorker

    data_consistency :sticky
    queue_namespace :feishu
    feature_category :duo_agent_platform
    urgency :low
    worker_has_external_dependencies!
    idempotent!
    # The ledger below makes a duplicate harmless; a deduplicated retry would
    # instead lose a reply that failed to send.
    deduplicate :none
    concurrency_limit -> { 100 }
    # Retries end well within the hour Feishu keeps a reply's uuid.
    sidekiq_options retry: 3

    LEDGER_TTL = 1.day

    sidekiq_retry_in do |_count, exception|
      exception.retry_after if exception.is_a?(::Gitlab::Feishu::AppResponse::RateLimited)
    end

    # @param user_id [Integer] the GitLab user the sender was bound to at callback time
    # @param params [Hash] 'app_id', 'chat_id', 'thread_id', 'sender_id', 'message_id' and 'text'
    # @return [void]
    def perform(user_id, params)
      @params = params
      # Feishu can push the same message again hours later, past the uuid's hour.
      return if ledger_entry('replied')

      reply = ledger_entry('reply')
      if reply.nil?
        return unless claim_turn

        reply = run_turn(user_id).to_s
        record('reply', reply)
      end

      send_reply(reply) if reply.present?
      record('replied', 1)

      nil
    end

    private

    attr_reader :params

    def run_turn(user_id)
      user = ::User.find_by_id(user_id)
      return unless eligible?(user)

      ::Gitlab::I18n.with_user_locale(user) do
        ::Ai::Messaging::FeishuTriggerService.new(
          user: user,
          app_id: params['app_id'],
          chat_id: params['chat_id'],
          thread_id: params['thread_id'],
          sender_id: params['sender_id'],
          message_id: params['message_id'],
          message: params['text']
        ).execute
      rescue StandardError => e
        # The claim is held, so this message is never run again; say so rather
        # than leave the user waiting.
        ::Gitlab::ErrorTracking.track_exception(e, feishu_message_id: params['message_id'])
        adapter.error_message(:execute_workflow_failed)
      end
    end

    # Re-checked here because the binding, the user and the flag can all change
    # between the callback and this job.
    def eligible?(user)
      return false unless user&.active?
      return false unless ::Feature.enabled?(:jh_feishu_duo_chat, user)

      chat_name = ::ChatNames::FindUserService.new(
        ::Gitlab::Chatops::FeishuBotHandler::BIND_TEAM_ID, params['sender_id']
      ).execute

      chat_name&.user_id == user.id
    end

    def send_reply(text)
      ::Gitlab::Feishu::BotClient.new.reply(
        params['message_id'],
        msg_type: 'post',
        content: ::Ai::Messaging::Adapters::Feishu.rich_text_content(text),
        uuid: "duo-reply-#{params['message_id']}"
      )
    rescue ::Gitlab::Feishu::AppResponse::PermanentError => e
      ::Gitlab::ErrorTracking.track_exception(e, feishu_message_id: params['message_id'])
    end

    def adapter
      ::Ai::Messaging::Adapters::Feishu.new(
        app_id: params['app_id'],
        chat_id: params['chat_id'],
        sender_id: params['sender_id'],
        message_id: params['message_id']
      )
    end

    def claim_turn
      ::Gitlab::Redis::SharedState.with { |redis| redis.set(ledger_key('turn'), 1, ex: LEDGER_TTL, nx: true) }
    end

    def ledger_entry(name)
      ::Gitlab::Redis::SharedState.with { |redis| redis.get(ledger_key(name)) }
    end

    def record(name, value)
      ::Gitlab::Redis::SharedState.with { |redis| redis.set(ledger_key(name), value, ex: LEDGER_TTL) }
    end

    def ledger_key(name)
      "feishu:duo_message:{#{params['app_id']}:#{params['message_id']}}:#{name}"
    end
  end
end
