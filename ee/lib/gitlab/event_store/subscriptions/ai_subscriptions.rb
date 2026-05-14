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
        end
      end
    end
  end
end
