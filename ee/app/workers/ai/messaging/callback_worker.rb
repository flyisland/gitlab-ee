# frozen_string_literal: true

module Ai
  module Messaging
    # Subscribes to WorkloadFinishedEvent to deliver agent results back to
    # the originating messaging service (Slack, Teams, etc.).
    #
    # Only acts on workflows that have a messaging_callback_context set --
    # all other workflows are silently skipped.
    #
    # rubocop:disable Scalability/IdempotentWorker -- EventStore::Subscriber includes idempotent
    class CallbackWorker
      include Gitlab::EventStore::Subscriber

      feature_category :duo_agent_platform

      # :delayed is safe -- event fires after_commit, so data is on replicas by execution time.
      data_consistency :delayed
      worker_has_external_dependencies!

      # Concrete adapters are registered in subsequent MRs.
      # e.g. { 'slack' => Ai::Messaging::Adapters::Slack }
      ADAPTER_REGISTRY = {}.freeze

      def handle_event(event)
        workload = ::Ci::Workloads::Workload.find_by_id(event.data[:workload_id])
        unless workload
          log_skip('Workload not found', event.data[:workload_id])
          return
        end

        workflow = workload.workflows.last
        unless workflow
          log_skip('No workflow associated with workload', event.data[:workload_id])
          return
        end

        callback_context = workflow.messaging_callback_context
        return unless callback_context.present? # Not a messaging-triggered workflow; expected no-op

        adapter = resolve_adapter(callback_context['adapter'])
        unless adapter
          Gitlab::AppLogger.warn(
            message: 'Duo Messaging: unknown adapter in callback context',
            adapter: callback_context['adapter'],
            workflow_id: workflow.id
          )
          return
        end

        if event.data[:status] == 'finished'
          deliver_success(adapter, callback_context, workflow)
        else
          adapter.on_flow_failed(callback_context: callback_context, error: :flow_failed)
        end
      end

      private

      def resolve_adapter(adapter_name)
        klass = ADAPTER_REGISTRY[adapter_name]
        return unless klass

        klass.new
      end

      def deliver_success(adapter, callback_context, workflow)
        message = extract_final_message(workflow)

        if message
          adapter.deliver_result(callback_context: callback_context, message: message)
          adapter.on_flow_completed(callback_context: callback_context, workflow: workflow)
        else
          adapter.on_flow_failed(callback_context: callback_context, error: :no_response)
        end
      end

      def extract_final_message(workflow)
        latest_checkpoint = workflow.checkpoints.latest
        return unless latest_checkpoint

        ui_chat_log = latest_checkpoint.checkpoint&.dig('channel_values', 'ui_chat_log')
        return unless ui_chat_log.is_a?(Array) && ui_chat_log.any?

        last_agent_message = ui_chat_log.reverse.detect { |m| m['message_type'] == 'agent' }
        last_agent_message&.dig('content')
      end

      def log_skip(reason, workload_id)
        Gitlab::AppLogger.info(
          message: "Duo Messaging: #{reason}",
          workload_id: workload_id
        )
      end
    end
    # rubocop:enable Scalability/IdempotentWorker
  end
end
