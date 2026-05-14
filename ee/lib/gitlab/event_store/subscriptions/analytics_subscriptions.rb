# frozen_string_literal: true

module Gitlab
  module EventStore
    module Subscriptions
      class AnalyticsSubscriptions < BaseSubscriptions
        def register
          store.subscribe ::Analytics::AiUsageEventsBackfillWorker, to: ::Analytics::ClickHouseForAnalyticsEnabledEvent
          store.subscribe ::Analytics::KnowledgeGraph::ExpireTraversalIdCacheWorker,
            to: ::ProjectAuthorizations::AuthorizationsAddedEvent,
            if: ->(_) { ::Feature.enabled?(:knowledge_graph_infra, :instance) }
          store.subscribe ::Analytics::KnowledgeGraph::ExpireTraversalIdCacheWorker,
            to: ::ProjectAuthorizations::AuthorizationsRemovedEvent,
            if: ->(_) { ::Feature.enabled?(:knowledge_graph_infra, :instance) }
          store.subscribe ::Analytics::KnowledgeGraph::ExpireTraversalIdCacheWorker,
            to: ::Members::MembersAddedEvent,
            if: ->(_) { ::Feature.enabled?(:knowledge_graph_infra, :instance) }
          store.subscribe ::Analytics::KnowledgeGraph::ExpireTraversalIdCacheWorker,
            to: ::Members::DestroyedEvent,
            if: ->(_) { ::Feature.enabled?(:knowledge_graph_infra, :instance) }
        end
      end
    end
  end
end
