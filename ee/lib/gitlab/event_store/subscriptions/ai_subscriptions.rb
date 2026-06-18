# frozen_string_literal: true

module Gitlab
  module EventStore
    module Subscriptions
      class AiSubscriptions < BaseSubscriptions
        def register
          store.subscribe ::Ai::ActiveContext::Code::CreateEnabledNamespaceEventWorker,
            to: ::Ai::ActiveContext::Code::CreateEnabledNamespaceEvent

          store.subscribe ::Ai::ActiveContext::Code::MarkRepositoryAsReadyEventWorker,
            to: ::Ai::ActiveContext::Code::MarkRepositoryAsReadyEvent

          store.subscribe ::Ai::ActiveContext::Code::MarkRepositoryAsPendingDeletionEventWorker,
            to: ::Ai::ActiveContext::Code::MarkRepositoryAsPendingDeletionEvent

          store.subscribe ::Ai::ActiveContext::Code::ProcessPendingEnabledNamespaceEventWorker,
            to: ::Ai::ActiveContext::Code::ProcessPendingEnabledNamespaceEvent

          store.subscribe ::Ai::ActiveContext::Code::ProcessInvalidEnabledNamespaceEventWorker,
            to: ::Ai::ActiveContext::Code::ProcessInvalidEnabledNamespaceEvent

          store.subscribe ::Ai::DuoWorkflows::UpdateWorkflowStatusEventWorker,
            to: ::Ci::Workloads::WorkloadFinishedEvent

          store.subscribe ::Ai::Messaging::CallbackWorker,
            to: ::Ci::Workloads::WorkloadFinishedEvent

          store.subscribe ::Ai::Messaging::CallbackWorker,
            to: ::Ai::DuoWorkflows::WorkflowStartedEvent

          # This executes AI Workflow Triggers for the Merge Requests ready
          store.subscribe ::MergeRequests::ExecuteMergeRequestReadyWorker,
            to: ::MergeRequests::DraftStateChangeEvent,
            if: ->(event) { event.data[:new_draft_status] == false }

          store.subscribe ::Ai::Catalog::Flows::ExecuteCodeConflictAiWorkflowTriggersWorker,
            to: ::MergeRequests::CodeConflictEvent

          store.subscribe ::Ai::Catalog::Flows::ExecuteMergeRequestApprovedWorkflowTriggersWorker,
            to: ::MergeRequests::ApprovedCloudEvent

          store.subscribe ::Ai::Catalog::Flows::ExecuteWorkItemCreatedWorkflowTriggersWorker,
            to: ::WorkItems::CreatedEvent,
            if: ->(event) {
              project_id = event.event_data[:project_id]
              project_id && ::Ai::FlowTrigger.for_projects(project_id).triggered_on(:work_item).exists?
            }
        end
      end
    end
  end
end
