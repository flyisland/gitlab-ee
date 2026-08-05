# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class WorkflowNote < ::ApplicationRecord
      include WorkflowLinkable

      self.table_name = :duo_workflows_workflow_notes

      links_workflow_to :note, class_name: 'Note', inverse_of: false

      enum :link_type, {
        # the note (comment) was created by the flow
        created: 1
      }, prefix: true
    end
  end
end
