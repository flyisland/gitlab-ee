# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class SessionArtifact < ::ApplicationRecord
      include FromUnion

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
      scope :in_namespace, ->(namespace) {
        namespace_ids = namespace.self_and_descendants.select(:id)
        project_ids = ::Project.in_namespace(namespace_ids).select(:id)
        # `unscoped` is intentional: without it each branch inherits the outer scope chain.
        # `remove_duplicates: false` (UNION ALL) is safe because the check constraint
        # `check_ff5e4d9247` guarantees num_nonnulls(namespace_id, project_id) = 1
        # a row can never appear in both branches, so deduplication is unnecessary overhead.
        ::Ai::DuoWorkflows::SessionArtifact.from_union(
          [
            unscoped.where(project_id: project_ids),
            unscoped.where(namespace_id: namespace.id)
          ],
          remove_duplicates: false
        )
      }
      scope :for_project_namespace, ->(project_namespace) { where(project_id: project_namespace.project.id) }
      scope :with_project, -> { includes(:project) }
      scope :with_keyset_order, -> {
        order(
          ::Gitlab::Pagination::Keyset::Order.build(
            [
              ::Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
                attribute_name: 'workflow_updated_at',
                order_expression: arel_table[:workflow_updated_at].desc,
                nullable: :not_nullable
              ),
              ::Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
                attribute_name: 'workflow_id',
                order_expression: arel_table[:workflow_id].desc,
                nullable: :not_nullable
              )
            ]
          )
        )
      }

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

      def web_path
        return unless project

        "#{Gitlab::Routing.url_helpers.project_automate_agent_sessions_path(project)}/#{workflow_id}"
      end

      private

      def project_or_namespace_present
        return if project_id.present? || namespace_id.present?

        errors.add(:base, 'one of project_id or namespace_id must be present')
      end
    end
  end
end
