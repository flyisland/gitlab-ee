# frozen_string_literal: true

module Types
  module Ai
    module DuoWorkflows
      # Join record between a GitLab Duo Agent Platform session and a work item.
      # Exposed from both directions: from a session (Workflow#work_item_links) and
      # from a work item (WorkItem#duo_workflow_links). The matching artifact for the
      # caller's direction is the "other" side of the link.
      class WorkflowWorkItemLinkType < Types::BaseObject
        graphql_name 'DuoWorkflowWorkItemLink'
        description 'Link between a GitLab Duo Agent Platform session and a work item.'
        authorize :read_duo_workflow
        authorize_granular_token permissions: :read_duo_workflow, boundary: :user, boundary_type: :user

        FIELD_SCOPES = [:api, :read_api, :ai_features, :ai_workflows].freeze

        field :link_type, Types::Ai::DuoWorkflows::WorkItemLinkTypeEnum,
          scopes: FIELD_SCOPES,
          null: false, description: 'How the work item relates to the session.'

        field :work_item, ::Types::WorkItemType,
          scopes: FIELD_SCOPES,
          null: true, description: 'Linked work item.'

        field :workflow, Types::Ai::DuoWorkflows::WorkflowType,
          scopes: FIELD_SCOPES,
          null: true, description: 'Linked GitLab Duo Agent Platform session.'

        field :created_at, Types::TimeType,
          scopes: FIELD_SCOPES,
          null: false, description: 'Timestamp of when the link was created.'
      end
    end
  end
end
