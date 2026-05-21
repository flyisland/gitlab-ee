# frozen_string_literal: true

module Gitlab
  module EventStore
    module Subscriptions
      class DependencyManagementSubscriptions < BaseSubscriptions
        def register
          store.subscribe ::DependencyManagement::SecurityUpdate::CreateMergeRequestWorker,
            to: ::Ci::PipelineFinishedEvent,
            if: ->(event) { dependency_management_pipeline?(event) }
        end

        private

        def dependency_management_pipeline?(event)
          ::Ci::Pipeline
            .id_in(event.data[:pipeline_id])
            .from_dependency_management
            .exists?
        end
      end
    end
  end
end
