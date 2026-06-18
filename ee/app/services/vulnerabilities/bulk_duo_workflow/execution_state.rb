# frozen_string_literal: true

module Vulnerabilities
  module BulkDuoWorkflow
    class ExecutionState
      include ::Vulnerabilities::BulkDuoWorkflow::StateKeys

      TTL = 7.days

      STATUS_RUNNING = :running
      STATUS_COMPLETED = :completed
      STATUS_FAILED = :failed
      STATUS_CANCELLED = :cancelled

      TERMINAL_STATES = [
        STATUS_COMPLETED,
        STATUS_FAILED,
        STATUS_CANCELLED
      ].freeze

      def initialize(project:, workflow_name:)
        @project = project
        @workflow_name = workflow_name.to_sym
      end

      def start!(fingerprint:)
        execution_id = SecureRandom.uuid

        scripts.start(
          execution_id: execution_id,
          fingerprint: fingerprint
        )

        execution_id
      end

      def cancel!(execution_id)
        scripts.cancel(execution_id: execution_id)
      end

      def active?
        status.present? && TERMINAL_STATES.exclude?(status)
      end

      def same_fingerprint?(fingerprint)
        metadata[:fingerprint] == fingerprint
      end

      def status
        metadata[:status]
      end

      def snapshot
        metadata.merge(workflow_name: workflow_name)
      end

      private

      def scripts
        @scripts ||= ExecutionScripts.new(
          redis: redis,
          keys: keys,
          ttl: TTL
        )
      end

      def metadata
        raw = redis.with { |r| r.hgetall(key(:metadata)) }

        {
          execution_id: raw['execution_id'],
          fingerprint: raw['fingerprint'],
          status: raw['status']&.to_sym,
          started_at: raw['started_at'],
          ended_at: raw['ended_at'].presence,
          cancel_requested: raw['cancel_requested'] == 'true'
        }
      end

      def redis
        Gitlab::Redis::SharedState
      end

      def keys
        { metadata: key(:metadata) }
      end
    end
  end
end
