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
        checkpoint = @workflow.checkpoints.new(checkpoint_attributes)

        return error(checkpoint.errors.full_messages, :bad_request) unless checkpoint.save

        update_workflow_goal_if_first_checkpoint(checkpoint)
        persist_model_metadata_if_present
        GraphqlTriggers.workflow_events_updated(checkpoint)
        success(checkpoint: checkpoint)
      end

      def checkpoint_attributes
        @params.except(:model_metadata_json).merge(workflow: @workflow)
      end

      # The workflow can be pre-created leaving its goal incomplete.
      def update_workflow_goal_if_first_checkpoint(checkpoint)
        # Using id.first because checkpoint ID is compound with the created_at,
        #  but minimum(:id) only retrieves the integer ID
        return unless @workflow.checkpoints.minimum(:id) == checkpoint.id.first

        goal = checkpoint.checkpoint.dig('channel_values', '__start__', 'goal')
        return if goal.blank?

        # goal is a denormalized copy of the full goal stored in the checkpoint's
        # channel_values; truncate to the column limit to avoid a validation 500.
        @workflow.update!(goal: goal.truncate(Workflow::GOAL_MAX_LENGTH, omission: ''))
      end

      private

      def persist_model_metadata_if_present
        model_metadata_json = @params[:model_metadata_json]
        return if model_metadata_json.blank?

        @workflow.update!(model_metadata_json: model_metadata_json)
      end
    end
  end
end
