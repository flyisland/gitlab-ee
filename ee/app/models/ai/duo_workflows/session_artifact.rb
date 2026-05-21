# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class SessionArtifact < ::ApplicationRecord
      self.table_name = 'duo_workflow_session_artifacts'

      belongs_to :workflow, class_name: 'Ai::DuoWorkflows::Workflow'
      belongs_to :project, optional: true
      belongs_to :namespace, optional: true
      belongs_to :user

      validates :workflow_id, presence: true, uniqueness: true
      validates :user_id, presence: true
      validates :status, presence: true
      validates :workflow_definition, presence: true, length: { maximum: 255 }
      validates :model_used, length: { maximum: 255 }
      validate :project_or_namespace_present

      # Uses upsert which intentionally bypasses model validations and callbacks
      # for performance. Data integrity is guaranteed by DB constraints and the
      # fact that we copy from an already-validated Workflow record.
      def self.sync_from_workflow!(workflow)
        upsert({
          workflow_id: workflow.id,
          user_id: workflow.user_id,
          project_id: workflow.project_id,
          namespace_id: workflow.namespace_id,
          status: workflow.status_before_type_cast,
          workflow_definition: workflow.workflow_definition,
          workflow_created_at: workflow.created_at,
          workflow_updated_at: workflow.updated_at
        }, unique_by: :workflow_id)
      end

      private

      def project_or_namespace_present
        return if project_id.present? || namespace_id.present?

        errors.add(:base, 'one of project_id or namespace_id must be present')
      end
    end
  end
end
