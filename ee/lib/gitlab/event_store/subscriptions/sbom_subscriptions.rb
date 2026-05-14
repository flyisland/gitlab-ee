# frozen_string_literal: true

module Gitlab
  module EventStore
    module Subscriptions
      class SbomSubscriptions < BaseSubscriptions
        def register
          store.subscribe ::Sbom::ProcessVulnerabilitiesWorker, to: ::Sbom::SbomIngestedEvent
          store.subscribe ::Sbom::CreateOccurrencesVulnerabilitiesWorker, to: ::Sbom::VulnerabilitiesCreatedEvent
          store.subscribe ::Sbom::ProcessTransferEventsWorker, to: ::Projects::ProjectTransferedEvent
          store.subscribe ::Sbom::ProcessTransferEventsWorker, to: ::Groups::GroupTransferedEvent
          store.subscribe ::Sbom::SyncArchivedStatusWorker, to: ::Projects::ProjectArchivedEvent
          store.subscribe ::Sbom::ProcessGroupArchivedEventsWorker,
            to: ::Namespaces::Groups::GroupArchivedEvent
          store.subscribe ::DependencyManagement::SecurityUpdate::SchedulerWorker,
            to: ::Sbom::VulnerabilitiesCreatedEvent,
            if: ->(event) {
              Array(event.data['findings']).any? { |f| f['purl_type'] == 'gem' }
            }
        end
      end
    end
  end
end
