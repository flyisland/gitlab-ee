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

          # Messaging callbacks are handled by exactly one worker, selected per
          # publish by the flag: on -> CallbackDispatchWorker, off -> the
          # pre-existing CallbackWorker (legacy). The flag also gates scheduling
          # the new worker until the Sidekiq fleet has the class
          # (see doc/development/sidekiq/compatibility_across_updates.md).
          dispatch_enabled = ->(_) { ::Feature.enabled?(:gitlab_duo_note_callback_high_urgency, :instance) }
          dispatch_disabled = ->(_) { !::Feature.enabled?(:gitlab_duo_note_callback_high_urgency, :instance) }

          store.subscribe ::Ai::Messaging::CallbackWorker,
            to: ::Ci::Workloads::WorkloadFinishedEvent,
            if: dispatch_disabled

          store.subscribe ::Ai::Messaging::CallbackWorker,
            to: ::Ai::DuoWorkflows::WorkflowStartedEvent,
            if: dispatch_disabled

          store.subscribe ::Ai::Messaging::CallbackDispatchWorker,
            to: ::Ci::Workloads::WorkloadFinishedEvent,
            if: dispatch_enabled

          store.subscribe ::Ai::Messaging::CallbackDispatchWorker,
            to: ::Ai::DuoWorkflows::WorkflowStartedEvent,
            if: dispatch_enabled

          store.subscribe ::Ai::Catalog::Flows::ExecuteMergeRequestReadyWorkflowTriggersWorker,
            to: ::MergeRequests::ReadyEvent

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

          store.subscribe ::Ai::Catalog::Flows::ExecuteWorkItemStatusChangedWorkflowTriggersWorker,
            to: ::WorkItems::StatusChangedEvent,
            if: ->(event) {
              ::Ai::FlowTrigger.registered_for?(event.event_data[:project_id], :work_item)
            }
        end
      end
    end
  end
end
