# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class CreateCheckpointService
      include ::Services::ReturnServiceResponses

      def initialize(workflow:, params:)
        @params = params
        @workflow = workflow
      end

      def execute
        is_first_checkpoint = !@workflow.checkpoints.exists?
        checkpoint = nil

        ApplicationRecord.transaction do
          checkpoint = @workflow.checkpoints.new(checkpoint_attributes)
          raise ActiveRecord::Rollback unless checkpoint.save

          if incremental_checkpoints_enabled? && channel_blobs_params.present?
            blobs = build_blobs_batch(checkpoint)
            # unique_by targets the dedup index; without it the conflict target
            # defaults to the composite PK, whose trigger-assigned id never collides.
            @workflow.checkpoint_blobs.bulk_insert!(
              blobs, skip_duplicates: true, unique_by: :idx_duo_wf_checkpoint_blobs_dedup
            )
          end
        end

        return error(checkpoint.errors.full_messages, :bad_request) unless checkpoint&.persisted?

        update_workflow_goal(checkpoint) if is_first_checkpoint
        persist_model_metadata_if_present
        GraphqlTriggers.workflow_events_updated(checkpoint)
        enqueue_messaging_progress_delivery
        success(checkpoint: checkpoint)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid, ArgumentError => e
        # ArgumentError covers a malformed base64 `data` payload from the gateway
        # (Base64.strict_decode64 in build_blobs_batch); return 400, not 500.
        error(e.message, :bad_request)
      end

      # Backfills a pre-created workflow's blank goal from the first checkpoint.
      # Web sets it at `__start__.goal`; a CLI-created session carries it at
      # `__start__.context.goal` instead, so fall back to that (else "Untitled").
      def update_workflow_goal(checkpoint)
        goal = checkpoint.checkpoint.dig('channel_values', '__start__', 'goal').presence ||
          checkpoint.checkpoint.dig('channel_values', '__start__', 'context', 'goal')
        return if goal.blank?

        # Truncate to the column limit to avoid a validation 500.
        @workflow.update!(goal: goal.truncate(Workflow::GOAL_MAX_LENGTH, omission: ''))
      end

      private

      # Live progress for messaging-triggered workflows. Gated on the adapter
      # opting in, and debounced (see ProgressDeliveryWorker) so quiet or
      # non-streaming workflows schedule nothing.
      def enqueue_messaging_progress_delivery
        return if @workflow.messaging_callback_context.blank?
        return unless messaging_adapter_supports_live_progress?

        ::Ai::Messaging::ProgressDeliveryWorker.perform_in(
          ::Ai::Messaging::ProgressDeliveryWorker::DEBOUNCE_INTERVAL, @workflow.id
        )
      end

      def messaging_adapter_supports_live_progress?
        adapter_key = @workflow.messaging_callback_context['adapter']
        adapter_class = ::Ai::Messaging::AdapterRegistry[adapter_key]
        adapter_class&.supports_live_progress?
      end

      def incremental_checkpoints_enabled?
        @workflow.incremental_checkpoints_enabled?
      end

      def checkpoint_attributes
        @params.except(:channel_blobs, :model_metadata_json).merge(workflow: @workflow)
      end

      def channel_blobs_params
        @params[:channel_blobs]
      end

      def build_blobs_batch(checkpoint)
        # Partition key: pins every blob to the workflow's daily partition. See
        # CheckpointBlob#partitioned_by.
        workflow_created_at = @workflow.created_at
        # bulk_insert! (insert_all) does not set timestamps, so set them here.
        now = Time.current
        channel_blobs_params.map do |attrs|
          # Detached instances (not `@workflow.checkpoint_blobs.new`): bulk_insert!
          # doesn't mark them persisted, so keeping them off the association avoids
          # a later `@workflow.update!` autosaving and re-inserting every blob.
          ::Ai::DuoWorkflows::CheckpointBlob.new(
            attrs.merge(
              workflow: @workflow,
              workflow_created_at: workflow_created_at,
              # Decode to raw bytes for the bytea column, dropping base64 overhead.
              data: Base64.strict_decode64(attrs[:data]),
              thread_ts: checkpoint.thread_ts,
              current_thread: checkpoint.current_thread,
              created_at: now,
              updated_at: now
            )
          )
        end
      end

      def persist_model_metadata_if_present
        model_metadata_json = @params[:model_metadata_json]
        return if model_metadata_json.blank?

        @workflow.update!(model_metadata_json: model_metadata_json)
      end
    end
  end
end
