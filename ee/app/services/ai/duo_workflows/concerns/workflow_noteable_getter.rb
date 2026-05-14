# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module Concerns
      module WorkflowNoteableGetter
        extend ActiveSupport::Concern

        private

        def find_noteable(workflow)
          workflow.issue.presence
        end

        def get_workflow_noteable(workflow)
          noteable = find_noteable(workflow)
          return unless noteable
          return unless noteable.respond_to?(:project) && noteable.project.present?

          noteable
        end
      end
    end
  end
end
