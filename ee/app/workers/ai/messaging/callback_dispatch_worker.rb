# frozen_string_literal: true

module Ai
  module Messaging
    # Sole EventStore subscriber for messaging-lifecycle events: delivers DB-only
    # adapters inline (the latency-sensitive @GitLabDuo reply path, hence :high)
    # and forwards external-dependency adapters (e.g. Slack) to CallbackWorker.
    #
    # rubocop:disable Scalability/IdempotentWorker -- EventStore::Subscriber includes idempotent
    class CallbackDispatchWorker
      include Gitlab::EventStore::Subscriber
      include Ai::Messaging::CallbackDispatch

      feature_category :duo_agent_platform
      data_consistency :sticky
      urgency :high # DB-only work only; external adapters are forwarded (see #forward_event)

      def handle_event(event)
        dispatch_event(event)
      end

      private

      def forward_event(adapter_class, event)
        return false unless adapter_class.has_external_dependencies?

        # .to_h mirrors how EventStore itself enqueues (plain JSON-native hash).
        ::Ai::Messaging::CallbackWorker.perform_async(event.class.name, event.data.deep_stringify_keys.to_h)
        true
      end
    end
    # rubocop:enable Scalability/IdempotentWorker
  end
end
