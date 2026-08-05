# frozen_string_literal: true

module Resolvers
  module Ai
    module DuoWorkflows
      class WorkItemDuoWorkflowLinksResolver < WorkflowLinksBaseResolver
        type Types::Ai::DuoWorkflows::WorkflowWorkItemLinkType.connection_type, null: true

        argument :link_type, Types::Ai::DuoWorkflows::WorkItemLinkTypeEnum,
          required: false,
          description: 'Filter links by their link type.'

        self.links_association = :duo_workflow_links
      end
    end
  end
end
