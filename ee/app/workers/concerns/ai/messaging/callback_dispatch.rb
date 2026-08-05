# frozen_string_literal: true

module Ai
  module Messaging
    # Shared messaging-lifecycle dispatch: resolves the adapter from a workflow's
    # messaging_callback_context and fires the matching lifecycle hook. Included by
    # CallbackDispatchWorker (forwards external adapters via #forward_event) and
    # CallbackWorker (terminal; uses the default no-op #forward_event).
    module CallbackDispatch
      extend ActiveSupport::Concern

      private

      # Each worker's #handle_event delegates here; the thin wrapper stays in the
      # worker so RuboCop's EventStoreSubscriber cop can see the required method.
      def dispatch_event(event)
        case event
        when ::Ci::Workloads::WorkloadFinishedEvent
          handle_workload_finished(event)
        when ::Ai::DuoWorkflows::WorkflowStartedEvent
          handle_workflow_started(event)
        end
      end

      # Return true if the event was handed off to another worker (skip inline
      # processing). Default: terminal worker, never forwards.
      def forward_event(_adapter_class, _event)
        false
      end

      def handle_workload_finished(event)
        workload = ::Ci::Workloads::Workload.find_by_id(event.data[:workload_id])
        unless workload
          log_skip('Workload not found', workload_id: event.data[:workload_id])
          return
        end

        workflow = workload.latest_workflow
        unless workflow
          log_skip('No workflow associated with workload', workload_id: event.data[:workload_id])
          return
        end

        with_adapter(workflow, event) do |adapter, callback_context|
          if event.data[:status] == 'finished'
            deliver_success(adapter, callback_context, workflow)
          else
            handle_error do
              adapter.on_flow_failed(callback_context: callback_context, error: :flow_failed, workflow: workflow)
            end
          end
        end
      end

      def handle_workflow_started(event)
        workflow = ::Ai::DuoWorkflows::Workflow.find_by_id(event.data[:workflow_id])
        unless workflow
          log_skip('Workflow not found', workflow_id: event.data[:workflow_id])
          return
        end

        with_adapter(workflow, event) do |adapter, callback_context|
          handle_error do
            adapter.on_flow_started(callback_context: callback_context, workflow: workflow)
          end
        end
      end

      def with_adapter(workflow, event)
        callback_context = workflow.messaging_callback_context
        return unless callback_context.present?

        klass = ::Ai::Messaging::AdapterRegistry[callback_context['adapter']]
        unless klass
          Gitlab::AppLogger.warn(
            message: 'Duo Messaging: unknown adapter in callback context',
            adapter: callback_context['adapter'],
            workflow_id: workflow.id
          )
          return
        end

        return if forward_event(klass, event)

        yield(klass.from_callback_context(callback_context), callback_context)
      end

      def deliver_success(adapter, callback_context, workflow)
        message = extract_final_message(workflow)

        if message
          handle_error { adapter.deliver_result(callback_context: callback_context, message: message) }
          handle_error { adapter.on_flow_completed(callback_context: callback_context, workflow: workflow) }
        else
          handle_error do
            adapter.on_flow_failed(callback_context: callback_context, error: :no_response, workflow: workflow)
          end
        end
      end

      def extract_final_message(workflow)
        latest_checkpoint = workflow.checkpoints.latest
        return unless latest_checkpoint

        last_agent_message = latest_checkpoint.ui_chat_log.reverse_each.detect { |m| m['message_type'] == 'agent' }
        last_agent_message&.dig('content')
      end

      def log_skip(reason, **identifiers)
        Gitlab::AppLogger.info(
          message: "Duo Messaging: #{reason}",
          **identifiers
        )
      end

      def handle_error
        yield
      rescue StandardError => e
        ::Gitlab::ErrorTracking.track_and_log_exception(e)
      end
    end
  end
end
