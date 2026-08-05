# frozen_string_literal: true

module Ai
  module Messaging
    # External-dependency delivery (e.g. Slack, whose lifecycle hooks call the
    # Slack API). Handles inline whatever adapter it is handed: forwarded events
    # from CallbackDispatchWorker once the dispatcher is active, or every adapter
    # while it is still the legacy EventStore subscriber (feature flag off).
    # Dispatch logic is shared via CallbackDispatch; this worker uses the default
    # terminal behavior (never forwards).
    #
    # rubocop:disable Scalability/IdempotentWorker -- EventStore::Subscriber includes idempotent
    class CallbackWorker
      include Gitlab::EventStore::Subscriber
      include Ai::Messaging::CallbackDispatch

      feature_category :duo_agent_platform

      # :sticky is the preferred consistency for jobs that should run as fast as possible: replicas
      # are guaranteed caught up to the enqueue point and the job falls back to the primary otherwise,
      # so there is no reschedule delay on replica lag.
      data_consistency :sticky
      worker_has_external_dependencies!

      def handle_event(event)
        dispatch_event(event)
      end
    end
    # rubocop:enable Scalability/IdempotentWorker
  end
end
