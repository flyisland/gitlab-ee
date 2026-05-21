# frozen_string_literal: true

module Gitlab
  module EventStore
    module Subscriptions
      class SearchSubscriptions < BaseSubscriptions # rubocop:disable Search/NamespacedClass -- Following EventStore pattern
        def register
          register_zoekt_events
          register_elastic_events
          register_finder_cache_events
        end

        private

        def register_finder_cache_events
          search_infra_enabled = ->(_) do
            ::Gitlab::CurrentSettings.elasticsearch_indexing? ||
              ::Gitlab::CurrentSettings.zoekt_indexing_enabled? ||
              knowledge_graph_infra_enabled?
          end

          [
            ::ProjectAuthorizations::AuthorizationsAddedEvent,
            ::ProjectAuthorizations::AuthorizationsRemovedEvent,
            ::Members::MembersAddedEvent,
            ::Members::DestroyedEvent,
            ::Members::UpdatedEvent,
            ::Members::AcceptedInviteEvent,
            ::Members::MembershipModifiedByAdminEvent
          ].each do |event_class|
            store.subscribe ::Search::ExpireFinderCacheWorker, to: event_class, if: search_infra_enabled
          end
        end

        def knowledge_graph_infra_enabled?
          ::Feature.enabled?(:knowledge_graph_infra, :instance) ||
            ::Gitlab.config.knowledge_graph['enabled']
        end

        def register_zoekt_events
          store.subscribe ::Search::Zoekt::DefaultBranchChangedWorker,
            to: ::Repositories::DefaultBranchChangedEvent

          store.subscribe ::Search::Zoekt::DeleteProjectEventWorker,
            to: ::Projects::ProjectDeletedEvent

          store.subscribe ::Search::Zoekt::TaskFailedEventWorker,
            to: ::Search::Zoekt::TaskFailedEvent

          store.subscribe ::Search::Zoekt::ProjectVisibilityChangedEventWorker,
            to: ::Projects::ProjectVisibilityChangedEvent

          store.subscribe ::Search::Zoekt::ProjectMarkedAsArchivedEventWorker,
            to: ::Projects::ProjectArchivedEvent

          store.subscribe ::Search::Zoekt::GroupArchivedEventWorker,
            to: ::Namespaces::Groups::GroupArchivedEvent

          store.subscribe ::Search::Zoekt::ProjectFeaturesChangedEventWorker,
            to: ::Projects::ProjectFeaturesChangedEvent

          store.subscribe ::Search::Zoekt::ProjectPathChangedEventWorker,
            to: ::Projects::ProjectPathChangedEvent

          store.subscribe ::Search::Zoekt::GroupPathChangedEventWorker,
            to: ::Namespaces::Groups::GroupPathChangedEvent

          store.subscribe ::Search::Zoekt::ForceUpdateOverprovisionedIndexEventWorker,
            to: ::Search::Zoekt::ForceUpdateOverprovisionedIndexEvent

          store.subscribe ::Search::Zoekt::IndexMarkAsPendingEvictionEventWorker,
            to: ::Search::Zoekt::IndexMarkPendingEvictionEvent

          store.subscribe ::Search::Zoekt::OrphanedIndexEventWorker,
            to: ::Search::Zoekt::OrphanedIndexEvent

          store.subscribe ::Search::Zoekt::IndexMarkedAsToDeleteEventWorker,
            to: ::Search::Zoekt::IndexMarkedAsToDeleteEvent

          store.subscribe ::Search::Zoekt::OrphanedRepoEventWorker,
            to: ::Search::Zoekt::OrphanedRepoEvent

          store.subscribe ::Search::Zoekt::RepoMarkedAsToDeleteEventWorker,
            to: ::Search::Zoekt::RepoMarkedAsToDeleteEvent

          store.subscribe ::Search::Zoekt::InitialIndexingEventWorker,
            to: ::Search::Zoekt::InitialIndexingEvent

          store.subscribe ::Search::Zoekt::LostNodeEventWorker,
            to: ::Search::Zoekt::LostNodeEvent

          store.subscribe ::Search::Zoekt::RepoToIndexEventWorker,
            to: ::Search::Zoekt::RepoToIndexEvent

          store.subscribe ::Search::Zoekt::RepoToReindexEventWorker,
            to: ::Search::Zoekt::RepoToReindexEvent

          store.subscribe ::Search::Zoekt::IndexToEvictEventWorker,
            to: ::Search::Zoekt::IndexToEvictEvent

          store.subscribe ::Search::Zoekt::NodeWithNegativeUnclaimedStorageEventWorker,
            to: ::Search::Zoekt::NodeWithNegativeUnclaimedStorageEvent

          store.subscribe ::Search::Zoekt::IndexMarkedAsReadyEventWorker,
            to: ::Search::Zoekt::IndexMarkedAsReadyEvent

          store.subscribe ::Search::Zoekt::UpdateIndexUsedStorageBytesEventWorker,
            to: ::Search::Zoekt::UpdateIndexUsedStorageBytesEvent

          store.subscribe ::Search::Zoekt::SaasRolloutEventWorker,
            to: ::Search::Zoekt::SaasRolloutEvent

          store.subscribe ::Search::Zoekt::TooManyReplicasEventWorker,
            to: ::Search::Zoekt::TooManyReplicasEvent
        end

        def register_elastic_events
          store.subscribe ::Search::ElasticDefaultBranchChangedWorker, to: ::Repositories::DefaultBranchChangedEvent,
            if: ->(_) { ::Gitlab::CurrentSettings.elasticsearch_indexing? }
          store.subscribe ::Search::Elastic::GroupArchivedEventWorker, to: ::Namespaces::Groups::GroupArchivedEvent,
            if: ->(_) { ::Gitlab::CurrentSettings.elasticsearch_indexing? }
          store.subscribe ::Search::Elastic::ProjectArchivedEventWorker, to: ::Projects::ProjectArchivedEvent,
            if: ->(_) { ::Gitlab::CurrentSettings.elasticsearch_indexing? }
        end
      end
    end
  end
end
