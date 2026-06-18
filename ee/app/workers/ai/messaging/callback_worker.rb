# frozen_string_literal: true

module Ai
  module Messaging
    # Messaging-lifecycle dispatcher for workflow events: resolves the adapter
    # from a workflow's messaging_callback_context and fires the matching
    # lifecycle hook. Only acts on workflows that have a
    # messaging_callback_context set -- all other workflows are silently skipped.
    #
    # rubocop:disable Scalability/IdempotentWorker -- EventStore::Subscriber includes idempotent
    class CallbackWorker
      include Gitlab::EventStore::Subscriber

      feature_category :duo_agent_platform

      # :sticky is the preferred consistency for jobs that should run as fast as possible: replicas
      # are guaranteed caught up to the enqueue point and the job falls back to the primary otherwise,
      # so there is no reschedule delay on replica lag -- which matters for user-facing replies
      # (e.g. @GitLabDuo MR mentions).
      data_consistency :sticky
      worker_has_external_dependencies!

      # Concrete adapters are registered here. Each adapter declares a unique
      # key and implements from_callback_context for async reconstruction.
      ADAPTER_REGISTRY = {
        ::Ai::Messaging::Adapters::Slack.adapter_key => ::Ai::Messaging::Adapters::Slack,
        ::Ai::Messaging::Adapters::GitlabDuoNote.adapter_key => ::Ai::Messaging::Adapters::GitlabDuoNote
      }.freeze

      def handle_event(event)
        case event
        when ::Ci::Workloads::WorkloadFinishedEvent
          handle_workload_finished(event)
        when ::Ai::DuoWorkflows::WorkflowStartedEvent
          handle_workflow_started(event)
        end
      end

      private

      def handle_workload_finished(event)
        workload = ::Ci::Workloads::Workload.find_by_id(event.data[:workload_id])
        unless workload
          log_skip('Workload not found', workload_id: event.data[:workload_id])
          return
        end

        workflow = workload.workflows.last
        unless workflow
          log_skip('No workflow associated with workload', workload_id: event.data[:workload_id])
          return
        end

        with_adapter(workflow) do |adapter, callback_context|
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

        with_adapter(workflow) do |adapter, callback_context|
          handle_error do
            adapter.on_flow_started(callback_context: callback_context, workflow: workflow)
          end
        end
      end

      # Resolves the messaging adapter for a workflow and yields it together with
      # its callback context. No-ops for non-messaging workflows (expected).
      def with_adapter(workflow)
        callback_context = workflow.messaging_callback_context
        return unless callback_context.present? # Not a messaging-triggered workflow; expected no-op

        adapter = resolve_adapter(callback_context)
        unless adapter
          Gitlab::AppLogger.warn(
            message: 'Duo Messaging: unknown adapter in callback context',
            adapter: callback_context['adapter'],
            workflow_id: workflow.id
          )
          return
        end

        yield(adapter, callback_context)
      end

      def resolve_adapter(callback_context)
        adapter_name = callback_context['adapter']
        klass = ADAPTER_REGISTRY[adapter_name]
        return unless klass

        klass.from_callback_context(callback_context)
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

        ui_chat_log = latest_checkpoint.checkpoint&.dig('channel_values', 'ui_chat_log')
        return unless ui_chat_log.is_a?(Array) && ui_chat_log.any?

        last_agent_message = ui_chat_log.reverse.detect { |m| m['message_type'] == 'agent' }
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
    # rubocop:enable Scalability/IdempotentWorker
  end
end
