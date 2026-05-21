# frozen_string_literal: true

module Subscriptions
  module Ai
    module DuoWorkflows
      class WorkflowEventsUpdated < BaseSubscription
        include Gitlab::Graphql::Laziness

        payload_type ::Types::Ai::DuoWorkflows::WorkflowEventType

        argument :workflow_id, Types::GlobalIDType[::Ai::DuoWorkflows::Workflow],
          required: true,
          description: 'Workflow ID to fetch duo workflow.'

        def authorized?(workflow_id:)
          unauthorized! unless current_user

          authorize_object_or_gid!(:read_duo_workflow, gid: workflow_id, object: object&.workflow)
        end
      end
    end
  end
end
