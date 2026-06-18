# frozen_string_literal: true

module Vulnerabilities
  module BulkDuoWorkflow
    class ExecutionScripts
      TERMINAL_STATUS_LUA_GUARD = <<~LUA.freeze
        if current_status == '#{::Vulnerabilities::BulkDuoWorkflow::ExecutionState::STATUS_COMPLETED}' or
           current_status == '#{::Vulnerabilities::BulkDuoWorkflow::ExecutionState::STATUS_FAILED}' or
           current_status == '#{::Vulnerabilities::BulkDuoWorkflow::ExecutionState::STATUS_CANCELLED}' then
          return current_status
        end
      LUA

      CANCEL_SCRIPT = ::Labkit::Redis::Script.new(<<~LUA.freeze)
        local current_execution_id =
          redis.call('HGET', KEYS[1], 'execution_id')

        if current_execution_id ~= ARGV[1] then
          return 'stale'
        end

        local current_status =
          redis.call('HGET', KEYS[1], 'status')

        #{TERMINAL_STATUS_LUA_GUARD}

        redis.call(
          'HSET',
          KEYS[1],
          'status', '#{::Vulnerabilities::BulkDuoWorkflow::ExecutionState::STATUS_CANCELLED}',
          'cancel_requested', 'true',
          'ended_at', ARGV[2]
        )

        return '#{::Vulnerabilities::BulkDuoWorkflow::ExecutionState::STATUS_CANCELLED}'
      LUA

      def initialize(redis:, keys:, ttl:)
        @redis = redis
        @keys = keys
        @ttl = ttl
      end

      def start(execution_id:, fingerprint:)
        timestamp = Time.current.iso8601

        redis.with do |r|
          r.multi do |multi|
            multi.hdel(keys[:metadata], 'ended_at')

            multi.hset(
              keys[:metadata],
              'execution_id', execution_id,
              'fingerprint', fingerprint,
              'status', ::Vulnerabilities::BulkDuoWorkflow::ExecutionState::STATUS_RUNNING,
              'started_at', timestamp,
              'cancel_requested', 'false'
            )

            multi.expire(keys[:metadata], ttl.to_i)
          end
        end

        execution_id
      end

      def cancel(execution_id:)
        timestamp = Time.current.iso8601

        redis.with do |r|
          CANCEL_SCRIPT.eval(
            r,
            keys: [keys[:metadata]],
            argv: [execution_id, timestamp]
          )
        end&.to_sym
      end

      private

      attr_reader :redis, :keys, :ttl
    end
  end
end
