# frozen_string_literal: true

module Ai
  module Messaging
    module Adapters
      class Base
        # Called by the callback worker when a flow finishes successfully.
        # @param callback_context [Hash] adapter-specific context stored on workflow
        # @param message [String] the agent's final response
        def deliver_result(callback_context:, message:)
          raise NotImplementedError, "#{self.class.name} must implement #deliver_result"
        end

        # Called when a flow fails or an error occurs during trigger.
        # @param callback_context [Hash] adapter-specific context
        # @param error [Symbol] e.g. :flow_not_enabled, :namespace_not_configured, :flow_failed
        def deliver_error(callback_context:, error:)
          raise NotImplementedError, "#{self.class.name} must implement #deliver_error"
        end

        # Optional lifecycle hooks -- adapters override if the platform supports them.
        #
        # Call-site conventions:
        # - on_flow_started: called by the trigger service caller (e.g. AppMentionedService),
        #   NOT by the callback worker.
        # - on_flow_completed / on_flow_failed: called by CallbackWorker.
        #
        # Future: on_checkpoint_created hook for streaming intermediate results.
        # Requires a new CheckpointCreatedEvent + CheckpointCallbackWorker.

        def on_flow_started(callback_context:, workflow:)
          # no-op by default
        end

        def on_flow_completed(callback_context:, workflow:)
          # no-op by default
        end

        # Called when the flow fails to start (trigger error) or fails during execution.
        def on_flow_failed(callback_context:, error:)
          deliver_error(callback_context: callback_context, error: error)
        end
      end
    end
  end
end
