# frozen_string_literal: true

module Ai
  module Messaging
    # Sole EventStore subscriber for messaging-lifecycle events (@GitLabDuo note
    # replies and Slack): resolves the adapter from the workflow's
    # messaging_callback_context and fires the matching lifecycle hook inline.
    # Marked as having external dependencies because some adapters (e.g. Slack)
    # call third-party APIs.
    #
    # rubocop:disable Scalability/IdempotentWorker -- EventStore::Subscriber includes idempotent
    class CallbackWorker
      include Gitlab::EventStore::Subscriber

      # Raised after a failed delivery so Sidekiq owns the retry. Inheriting
      # RetryError keeps the expected retry out of Sentry and the execution SLI;
      # the underlying adapter error was already tracked once at its source.
      DeliveryRetryError = Class.new(::Gitlab::SidekiqMiddleware::RetryError)

      feature_category :duo_agent_platform

      # :sticky is the preferred consistency for jobs that should run as fast as possible: replicas
      # are guaranteed caught up to the enqueue point and the job falls back to the primary otherwise,
      # so there is no reschedule delay on replica lag.
      data_consistency :sticky
      worker_has_external_dependencies!

      # Without this the DeliveryRetryError raise would inherit Sidekiq's default 25.
      sidekiq_options retry: 3

      sidekiq_retries_exhausted do |job, exception|
        # Runs outside the job context and Sidekiq swallows raises from this block, so
        # keep it a bare log. Array.wrap: Subscriber can batch the data arg. error_class
        # says what exhausted the shared retry budget (a dropped delivery vs anything else).
        data = Array.wrap(job['args'].second).first.to_h

        Gitlab::AppLogger.warn(
          message: 'Duo Messaging: retries exhausted; giving up',
          error_class: exception&.class&.name,
          workflow_id: data['workflow_id'],
          workload_id: data['workload_id']
        )
      end

      def handle_event(event)
        case event
        when ::Ci::Workloads::WorkloadFinishedEvent
          handle_workload_finished(event)
        when ::Ai::DuoWorkflows::WorkflowStartedEvent
          handle_workflow_started(event)
        when ::Ai::DuoWorkflows::WorkflowFinishedEvent
          handle_workflow_finished(event)
        end
      end

      private

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

        with_adapter(workflow) do |adapter, callback_context|
          if event.data[:status] == 'finished' || workflow.finished?
            # Success normally rides the earlier WorkflowFinishedEvent; this is the last
            # event for the run, so it is the backstop when that delivery never landed.
            deliver_success(adapter, callback_context, workflow)
          else
            handle_error do
              adapter.on_flow_failed(callback_context: callback_context, error: :flow_failed, workflow: workflow)
            end
          end
        end
      end

      def handle_workflow_finished(event)
        workflow = ::Ai::DuoWorkflows::Workflow.find_by_id(event.data[:workflow_id])
        unless workflow
          log_skip('Workflow not found', workflow_id: event.data[:workflow_id])
          return
        end

        with_adapter(workflow) do |adapter, callback_context|
          deliver_success(adapter, callback_context, workflow)
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

      def with_adapter(workflow)
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

        yield(klass.from_callback_context(callback_context), callback_context)
      end

      # Fast path (WorkflowFinishedEvent) and backstop (WorkloadFinishedEvent) can land
      # mid-delivery of each other; the atomic claim picks one winner. Only the failing
      # job knows its delivery failed, so it raises for its own Sidekiq retry.
      def deliver_success(adapter, callback_context, workflow)
        if already_delivered?(workflow)
          log_skip('Terminal outcome already delivered', workflow_id: workflow.id)
          return
        end

        # Read before claiming: this checkpoint read is not error-wrapped, and a raise
        # after a claim would strand it (the retry would then skip at the guard above).
        message = extract_final_message(workflow.latest_ui_chat_log)

        unless workflow.claim_messaging_callback_delivery
          # The holder owns the outcome either way: success needs nothing from us, and
          # failure raises for its own Sidekiq retry. Stand down.
          log_skip('Delivery claimed by concurrent job', workflow_id: workflow.id)
          return
        end

        unless message
          # The final checkpoint is persisted before the finish transition fires, so a
          # message missing now stays missing: the claim is kept because the outcome is
          # terminal whether or not the error itself reaches the user.
          handle_error do
            adapter.on_flow_failed(callback_context: callback_context, error: :no_response, workflow: workflow)
          end

          return
        end

        delivered = handle_error do
          adapter.deliver_result(callback_context: callback_context, message: message, workflow: workflow)
        end

        unless delivered
          # on_flow_completed is held back so the surface isn't marked answered
          # (Slack's white_check_mark) with no answer on it. Release BEFORE raising:
          # the Sidekiq retry re-enters handle_event and must pass the guard above.
          workflow.release_messaging_callback_delivery!
          log_skip('Result delivery failed; released claim for Sidekiq retry', workflow_id: workflow.id)

          raise DeliveryRetryError, "Result delivery failed for workflow #{workflow.id}"
        end

        handle_error { adapter.on_flow_completed(callback_context: callback_context, workflow: workflow) }
      end

      def already_delivered?(workflow)
        workflow.messaging_callback_context['delivered_at'].present?
      end

      # The ui_chat_log is cumulative: the latest checkpoint contains the full
      # log. Search from the end for the last agent message with non-blank
      # content and no tool calls, so that a trailing empty or tool-call-only
      # agent turn (e.g. after a final tool call like marking todos complete)
      # does not suppress the real response.
      def extract_final_message(chat_log)
        chat_log.reverse_each.detect do |m|
          m['message_type'] == 'agent' && m['content'].present? && m['tool_calls'].blank?
        end&.dig('content')
      end

      def log_skip(reason, **identifiers)
        Gitlab::AppLogger.info(
          message: "Duo Messaging: #{reason}",
          **identifiers
        )
      end

      # Returns nil once it swallows an error, so deliver_success reads a raised
      # delivery the same way it reads an adapter reporting one: not delivered.
      def handle_error
        yield
      rescue StandardError => e
        ::Gitlab::ErrorTracking.track_exception(e)
        nil
      end
    end
    # rubocop:enable Scalability/IdempotentWorker
  end
end
