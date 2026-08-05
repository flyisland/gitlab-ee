# frozen_string_literal: true

module Vulnerabilities
  module BulkDuoWorkflow
    class ExecutionState
      include ::Vulnerabilities::BulkDuoWorkflow::StateKeys

      TTL = 7.days
      BATCH_SIZE = 100

      STATUS_CREATED = :created
      STATUS_RUNNING = :running
      STATUS_COMPLETED = :completed
      STATUS_FAILED = :failed
      STATUS_CANCELLED = :cancelled

      RESULT_NOT_FOUND = :not_found
      RESULT_INVALID = :invalid

      PROJECT_ID_REQUIRED = 'project_id is required'
      WORKFLOW_REQUIRED = 'workflow is required'

      TERMINAL_STATES = [
        STATUS_COMPLETED,
        STATUS_FAILED,
        STATUS_CANCELLED
      ].freeze

      attr_reader :execution_id

      def self.current(project_id:, workflow:)
        execution_id = redis.with do |r|
          r.get(
            StateKeys.current_execution_key(
              project_id: project_id,
              workflow: workflow
            )
          )
        end

        return unless execution_id

        execution = new(
          execution_id: execution_id,
          project_id: project_id,
          workflow: workflow
        )

        return execution if execution.active?

        nil
      end

      def self.create!(project_id:, workflow:, stages:, batch_size: BATCH_SIZE, metadata: {})
        execution_id = SecureRandom.uuid

        execution = new(
          execution_id: execution_id,
          project_id: project_id,
          workflow: workflow
        )

        actual_execution_id = execution.create!(
          stages: stages,
          batch_size: batch_size,
          metadata: metadata
        )

        return execution if actual_execution_id == execution.execution_id

        new(
          execution_id: actual_execution_id,
          project_id: project_id,
          workflow: workflow
        )
      end

      def self.redis
        Gitlab::Redis::SharedState
      end

      def initialize(execution_id:, project_id:, workflow:)
        raise ArgumentError, PROJECT_ID_REQUIRED if project_id.nil?
        raise ArgumentError, WORKFLOW_REQUIRED if workflow.nil?

        @execution_id = execution_id
        @project_id = project_id
        @workflow = workflow
      end

      def create!(stages:, batch_size:, metadata: {})
        scripts.create(
          execution_id: execution_id,
          project_id: project_id,
          workflow: workflow,
          stages: stages,
          batch_size: batch_size,
          metadata: metadata
        )
      end

      def append_to_stage!(stage:, item_ids:)
        state.append_stage!(
          index: stage_order(stage),
          item_ids: item_ids
        )
      end

      def start!
        scripts.start
      end

      def cancel!
        transition!(STATUS_CANCELLED)
      end

      def complete!
        transition!(STATUS_COMPLETED)
      end

      def fail!
        transition!(STATUS_FAILED)
      end

      def start_processing!(item_ids)
        state.start_processing!(item_ids)
      end

      def mark_completed!(item_ids)
        result = state.mark_completed!(item_ids)

        case result
        when VulnerabilityScripts::RESULTS[:stage_complete]
          start_next_batch if state.claim_stage_enqueue!
        when VulnerabilityScripts::RESULTS[:batch_complete]
          start_next_batch if state.claim_batch_enqueue!
        end

        result
      end

      def mark_failed!(item_ids)
        state.mark_failed!(item_ids)
      end

      def mark_cancelled!(item_ids)
        state.mark_cancelled!(item_ids)
      end

      def active?
        status.present? && TERMINAL_STATES.exclude?(status)
      end

      def status
        metadata[:status]
      end

      def batch_size
        metadata[:batch_size]
      end

      def workflow_metadata
        metadata[:metadata]
      end

      def next_batch
        limit = batch_size
        limit = BATCH_SIZE if limit <= 0

        state.pending_ids(limit: limit)
      end

      def snapshot
        metadata.merge(
          pending_ids: state.pending_ids,
          processing_ids: state.processing_ids,
          completed_ids: state.completed_ids,
          failed_ids: state.failed_ids,
          cancelled_ids: state.cancelled_ids
        )
      end

      private

      attr_reader :project_id, :workflow

      def transition!(status)
        scripts.transition(
          execution_id: execution_id,
          status: status
        )
      end

      def start_next_batch
        item_ids = next_batch
        return if item_ids.empty?

        state.start_processing!(item_ids)
      end

      def state
        @state ||= VulnerabilityState.new(execution_id: execution_id, project_id: project_id, workflow: workflow)
      end

      def scripts
        @scripts ||= ExecutionScripts.new(
          redis: self.class.redis,
          keys: keys,
          ttl: TTL
        )
      end

      def metadata
        raw = self.class.redis.with { |r| r.hgetall(keys[:metadata]) }

        {
          execution_id: raw['execution_id'],
          project_id: raw['project_id'],
          workflow: raw['workflow']&.to_sym,
          status: raw['status']&.to_sym,
          created_at: raw['created_at'],
          started_at: raw['started_at'],
          ended_at: raw['ended_at'].presence,
          cancel_requested: raw['cancel_requested'] == 'true',
          batch_size: raw['batch_size'].to_i,
          processed_in_batch: raw['processed_in_batch'].to_i,
          current_stage: raw['current_stage'].to_i,
          stages: ::Gitlab::Json.safe_parse(raw['stages'] || '[]'),
          metadata: ::Gitlab::Json.safe_parse(raw['metadata'] || '{}')
        }
      end

      def stage_order(stage_name)
        stage = metadata[:stages].find { |definition| definition['name'] == stage_name.to_s }

        raise ArgumentError, "unknown stage: #{stage_name}" unless stage

        stage.fetch('order')
      end

      def current_key
        StateKeys.current_execution_key(
          project_id: project_id,
          workflow: workflow
        )
      end

      def keys
        @keys ||= {
          metadata: key(:metadata),
          current: current_key
        }
      end
    end
  end
end
