# frozen_string_literal: true

module Gitlab
  module EventStore
    module Subscriptions
      class ClustersSubscriptions < BaseSubscriptions
        def register
          register_work_item_subscriptions
          register_merge_request_subscriptions
        end

        private

        def register_work_item_subscriptions
          store.subscribe ::Clusters::Agents::AutoFlow::WorkItems::CreatedEventWorker,
            to: ::WorkItems::WorkItemCreatedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.issue_events_enabled?(event.data[:id]) }
          store.subscribe ::Clusters::Agents::AutoFlow::WorkItems::UpdatedEventWorker,
            to: ::WorkItems::WorkItemUpdatedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.issue_events_enabled?(event.data[:id]) }
          store.subscribe ::Clusters::Agents::AutoFlow::WorkItems::ClosedEventWorker,
            to: ::WorkItems::WorkItemClosedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.issue_events_enabled?(event.data[:id]) }
          store.subscribe ::Clusters::Agents::AutoFlow::WorkItems::ReopenedEventWorker,
            to: ::WorkItems::WorkItemReopenedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.issue_events_enabled?(event.data[:id]) }
        end

        def register_merge_request_subscriptions
          store.subscribe ::Clusters::Agents::AutoFlow::MergeRequests::CreatedEventWorker,
            to: ::MergeRequests::CreatedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.merge_request_events_enabled?(event.data[:merge_request_id]) }
          store.subscribe ::Clusters::Agents::AutoFlow::MergeRequests::UpdatedEventWorker,
            to: ::MergeRequests::UpdatedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.merge_request_events_enabled?(event.data[:merge_request_id]) }
          store.subscribe ::Clusters::Agents::AutoFlow::MergeRequests::MergedEventWorker,
            to: ::MergeRequests::MergedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.merge_request_events_enabled?(event.data[:merge_request_id]) }
          store.subscribe ::Clusters::Agents::AutoFlow::MergeRequests::ClosedEventWorker,
            to: ::MergeRequests::ClosedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.merge_request_events_enabled?(event.data[:merge_request_id]) }
          store.subscribe ::Clusters::Agents::AutoFlow::MergeRequests::ReopenedEventWorker,
            to: ::MergeRequests::ReopenedEvent,
            if: ->(event) { ::Clusters::Agents::AutoFlow.merge_request_events_enabled?(event.data[:merge_request_id]) }
        end
      end
    end
  end
end
