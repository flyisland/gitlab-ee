# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::EventStore, feature_category: :shared do
  describe '.instance' do
    it 'returns a store with CE and EE subscriptions' do
      instance = described_class.instance

      expect(instance.subscriptions.keys).to match_array([
        Ai::ActiveContext::Code::CreateEnabledNamespaceEvent,
        Ai::ActiveContext::Code::MarkRepositoryAsReadyEvent,
        Ai::ActiveContext::Code::MarkRepositoryAsPendingDeletionEvent,
        Ai::ActiveContext::Code::ProcessPendingEnabledNamespaceEvent,
        Ai::ActiveContext::Code::ProcessInvalidEnabledNamespaceEvent,
        ::Ci::JobArtifactsDeletedEvent,
        ::Ci::JobSecurityScanCompletedEvent,
        ::Ci::PipelineCreatedEvent,
        ::Ci::PipelineFinishedEvent,
        ::Ci::Workloads::WorkloadFinishedEvent,
        ::Repositories::KeepAroundRefsCreatedEvent,
        ::MergeRequests::ApprovedEvent,
        ::MergeRequests::MergedEvent,
        ::MergeRequests::AutoMerge::TitleDescriptionUpdateEvent,
        ::MergeRequests::ApprovalsResetEvent,
        ::MergeRequests::DraftStateChangeEvent,
        ::MergeRequests::UnblockedStateEvent,
        ::MergeRequests::OverrideRequestedChangesStateEvent,
        ::MergeRequests::DiscussionsResolvedEvent,
        ::MergeRequests::MergeableEvent,
        ::MergeRequests::ViolationsUpdatedEvent,
        ::MergeRequests::ClosedEvent,
        ::MergeRequests::CreatedEvent,
        ::MergeRequests::ReopenedEvent,
        ::MergeRequests::UpdatedEvent,
        ::MergeRequests::DraftNotePublishedEvent,
        ::GitlabSubscriptions::RenewedEvent,
        ::Repositories::DefaultBranchChangedEvent,
        ::Repositories::RepositoryCreatedEvent,
        ::NamespaceSettings::AiRelatedSettingsChangedEvent,
        ::Members::DestroyedEvent,
        ::Members::MembersAddedEvent,
        ::Namespaces::Groups::GroupArchivedEvent,
        ::Namespaces::Groups::GroupPathChangedEvent,
        ::ProjectAuthorizations::AuthorizationsChangedEvent,
        ::ProjectAuthorizations::AuthorizationsRemovedEvent,
        ::ProjectAuthorizations::AuthorizationsAddedEvent,
        ::Projects::ComplianceFrameworkChangedEvent,
        ::Projects::SecurityAttributeChangedEvent,
        ::ContainerRegistry::ImagePushedEvent,
        Projects::ProjectPathChangedEvent,
        Projects::ProjectTransferedEvent,
        Projects::ProjectVisibilityChangedEvent,
        Groups::GroupTransferedEvent,
        Groups::GroupDeletedEvent,
        Projects::ProjectArchivedEvent,
        Projects::ProjectFeaturesChangedEvent,
        ::Pages::Domains::PagesDomainDeletedEvent,
        Vulnerabilities::LinkToExternalIssueTrackerCreated,
        Vulnerabilities::LinkToExternalIssueTrackerRemoved,
        WorkItems::WorkItemClosedEvent,
        WorkItems::WorkItemCreatedEvent,
        WorkItems::WorkItemDeletedEvent,
        WorkItems::WorkItemReopenedEvent,
        WorkItems::WorkItemUpdatedEvent,
        PackageMetadata::IngestedAdvisoryEvent,
        MergeRequests::ExternalStatusCheckPassedEvent,
        Packages::PackageCreatedEvent,
        Projects::ProjectCreatedEvent,
        Projects::ProjectDeletedEvent,
        ::Milestones::MilestoneUpdatedEvent,
        ::WorkItems::BulkUpdatedEvent,
        ::Users::ActivityEvent,
        Sbom::VulnerabilitiesCreatedEvent,
        Sbom::SbomIngestedEvent,
        Search::Zoekt::ForceUpdateOverprovisionedIndexEvent,
        Search::Zoekt::IndexMarkedAsReadyEvent,
        Search::Zoekt::IndexMarkedAsToDeleteEvent,
        Search::Zoekt::IndexMarkPendingEvictionEvent,
        Search::Zoekt::IndexToEvictEvent,
        Search::Zoekt::InitialIndexingEvent,
        Search::Zoekt::LostNodeEvent,
        Search::Zoekt::NodeWithNegativeUnclaimedStorageEvent,
        Search::Zoekt::OrphanedIndexEvent,
        Search::Zoekt::OrphanedRepoEvent,
        Search::Zoekt::RepoMarkedAsToDeleteEvent,
        Search::Zoekt::RepoToIndexEvent,
        Search::Zoekt::RepoToReindexEvent,
        Search::Zoekt::TaskFailedEvent,
        Search::Zoekt::UpdateIndexUsedStorageBytesEvent,
        Search::Zoekt::SaasRolloutEvent,
        Search::Zoekt::TooManyReplicasEvent,
        Security::PolicyCreatedEvent,
        Security::PolicyUpdatedEvent,
        Security::PolicyDeletedEvent,
        Security::PolicyResyncEvent,
        Security::PolicyDismissalPreservedEvent,
        Security::ReportsIngestedEvent,
        ::Members::MembershipModifiedByAdminEvent,
        ::Members::UpdatedEvent,
        ::Members::AcceptedInviteEvent,
        Repositories::ProtectedBranchCreatedEvent,
        Repositories::ProtectedBranchDestroyedEvent,
        Vulnerabilities::BulkDismissedEvent,
        Vulnerabilities::BulkRedetectedEvent,
        ::Analytics::ClickHouseForAnalyticsEnabledEvent
      ])
    end
  end

  describe '.publish_group' do
    let(:events) { [] }

    it 'calls publish_group of instance' do
      expect(described_class.instance).to receive(:publish_group).with(events)

      described_class.publish_group(events)
    end
  end

  describe 'virtual registries subscriptions' do
    expected_subscriptions = {
      ::Projects::ProjectDeletedEvent => ::VirtualRegistries::DestroyLocalUpstreamsWorker,
      ::Groups::GroupDeletedEvent => ::VirtualRegistries::DestroyLocalUpstreamsWorker
    }

    subscriptions = described_class.instance.subscriptions

    expected_subscriptions.each do |event_class, worker_class|
      it "subscribes #{worker_class} to #{event_class}" do
        expect(subscriptions[event_class]).to include(have_attributes(worker: worker_class))
      end
    end
  end

  describe 'Vulnerabilities::AutoDismissWorker subscription' do
    let(:subscriptions) { described_class.instance.subscriptions }

    it 'subscribes Vulnerabilities::AutoDismissWorker to Sbom::VulnerabilitiesCreatedEvent' do
      expect(subscriptions[Sbom::VulnerabilitiesCreatedEvent]).to include(
        have_attributes(worker: ::Vulnerabilities::AutoDismissWorker)
      )
    end
  end

  describe 'DependencyManagement::SecurityUpdate::SchedulerWorker subscription',
    feature_category: :dependency_management do
    let(:subscriptions) { described_class.instance.subscriptions }

    it 'subscribes to Sbom::SbomIngestedEvent' do
      expect(subscriptions[Sbom::SbomIngestedEvent]).to include(
        have_attributes(worker: DependencyManagement::SecurityUpdate::SchedulerWorker)
      )
    end
  end

  describe 'TestRunCompletionWorker subscription', feature_category: :security_policy_management do
    let(:subscriptions) { described_class.instance.subscriptions }
    let(:subscription) do
      subscriptions[Ci::PipelineFinishedEvent].find do |s|
        s.worker == Security::PipelineExecutionSchedulePolicies::TestRunCompletionWorker
      end
    end

    let_it_be(:ci_pipeline) { create(:ci_pipeline) }

    it 'subscribes to Ci::PipelineFinishedEvent' do
      expect(subscription).to be_present
    end

    context 'when test run exists for pipeline' do
      before do
        create(:security_pipeline_execution_policy_test_run, pipeline: ci_pipeline)
      end

      it 'returns true' do
        event = Ci::PipelineFinishedEvent.new(data: { pipeline_id: ci_pipeline.id, status: 'success' })

        expect(subscription.condition.call(event)).to be(true)
      end
    end

    context 'when no test run exists for pipeline' do
      it 'returns false' do
        event = Ci::PipelineFinishedEvent.new(data: { pipeline_id: ci_pipeline.id, status: 'success' })

        expect(subscription.condition.call(event)).to be(false)
      end
    end
  end

  describe 'ExecuteMergeRequestReadyWorker subscription', feature_category: :code_suggestions do
    let(:subscriptions) { described_class.instance.subscriptions }
    let(:subscription) do
      subscriptions[MergeRequests::DraftStateChangeEvent].find do |s|
        s.worker == MergeRequests::ExecuteMergeRequestReadyWorker
      end
    end

    it 'subscribes to MergeRequests::DraftStateChangeEvent' do
      expect(subscription).to be_present
    end

    context 'when new_draft_status is false (MR became ready)' do
      it 'returns true' do
        event = MergeRequests::DraftStateChangeEvent.new(
          data: { current_user_id: 1, merge_request_id: 1, new_draft_status: false }
        )

        expect(subscription.condition.call(event)).to be(true)
      end
    end

    context 'when new_draft_status is true (MR became draft)' do
      it 'returns false' do
        event = MergeRequests::DraftStateChangeEvent.new(
          data: { current_user_id: 1, merge_request_id: 1, new_draft_status: true }
        )

        expect(subscription.condition.call(event)).to be(false)
      end
    end
  end
end
