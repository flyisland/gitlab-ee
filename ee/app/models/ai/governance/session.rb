# frozen_string_literal: true

module Ai
  module Governance
    class Session < ApplicationRecord
      self.table_name = 'ai_governance_sessions'

      # namespace_id has a loose FK (config/gitlab_loose_foreign_keys.yml) that deletes the
      # session when its namespace is deleted. project_id, user_id and workflow_id have no
      # foreign key at all, so their ids can dangle after the target is gone. Every association
      # is optional so a session stays readable and writable in the window before that cleanup
      # runs; `namespace_id` and `user_id` are still required by the validations below and NOT
      # NULL in the database, so the ids are always recorded up to that point.
      belongs_to :namespace, optional: true
      belongs_to :project, optional: true
      belongs_to :user, optional: true
      belongs_to :workflow, class_name: '::Ai::DuoWorkflows::Workflow', optional: true
      belongs_to :agent_identity, class_name: '::Ai::ExternalAgents::AgentIdentity', optional: true

      enum :source, {
        gitlab_duo: 0,
        claude_code_compliance_api: 1,
        claude_code_glab: 2,
        mcp: 3
      }
      # Mirrors Ai::DuoWorkflows::Workflow's state_machine :status values exactly, so
      # .sync_from_workflow! needs no translation. This table does not own these values: if
      # a state is ever added there, it must be added here too, or the upsert stores an
      # integer this enum cannot name and the row reads back with a nil status.
      enum :status, {
        created: 0,
        running: 1,
        paused: 2,
        finished: 3,
        failed: 4,
        stopped: 5,
        input_required: 6,
        plan_approval_required: 7,
        tool_call_approval_required: 8
      }

      validates :namespace_id, presence: true
      validates :user_id, presence: true
      validates :session_started_at, presence: true
      validates :external_xid, length: { maximum: 255 },
        uniqueness: { scope: [:namespace_id, :source] }, allow_nil: true
      # Backs i_ai_governance_sessions_on_namespace_workflow: one row per Duo workflow, so the
      # sync worker's upsert has a real key to upsert against instead of inserting a duplicate
      # on every status change.
      validates :workflow_id, uniqueness: { scope: :namespace_id }, allow_nil: true
      validates :agent_type, length: { maximum: 50 }
      validates :flow_type, length: { maximum: 255 }
      # A Duo-sourced row links to a real Ai::DuoWorkflows::Workflow via workflow_id; an
      # external-agent-sourced row is identified by external_xid instead. Never both, never
      # neither, so a session's provenance is always unambiguous. Mirrored at the database
      # level by check_ai_session_is_duo_or_external, so writes that bypass validations
      # (insert_all, update_column, raw SQL) can't violate it either.
      validates_with ExactlyOnePresentValidator, fields: %i[workflow_id external_xid]

      scope :for_namespace, ->(namespace_id) { where(namespace_id: namespace_id) }
      scope :for_project, ->(project) { where(project_id: project.id) }
      scope :for_user, ->(user_id) { where(user_id: user_id) }
      scope :for_agent_type, ->(agent_type) { where(agent_type: agent_type) }
      scope :for_status, ->(status) { where(status: status) }
      scope :created_after, ->(time) { where(session_started_at: time..) }
      scope :created_before, ->(time) { where(session_started_at: ..time) }
      scope :ordered_by_id_desc, -> { order(id: :desc) }
      scope :glab_external, -> { where(source: :claude_code_glab) }

      # Mirrors Ai::DuoWorkflows::SessionArtifact.sync_from_workflow!, including its
      # reasons for upserting past validations and callbacks.
      #
      # `unique_by` names the index so the `ON CONFLICT` target carries its
      # `WHERE workflow_id IS NOT NULL` predicate, which Postgres needs to infer a
      # partial unique index. `session_finished_at` is omitted because another writer owns
      # it, so a sync never resets it.
      def self.sync_from_workflow!(workflow)
        upsert({
          workflow_id: workflow.id,
          user_id: workflow.user_id,
          project_id: workflow.project_id,
          namespace_id: workflow.namespace_id || workflow.project.project_namespace_id,
          status: workflow.status_before_type_cast,
          flow_type: workflow.workflow_definition,
          agent_type: workflow.agent_type,
          source: :gitlab_duo,
          session_started_at: workflow.created_at
        }, unique_by: :i_ai_governance_sessions_on_namespace_workflow)
      end

      DISTRIBUTION_FALLBACK_NAME = 'unknown'

      scope :for_agent_class, ->(agent_class) do
        case agent_class
        when :internal_dap then where(source: :gitlab_duo)
        when :external then where.not(source: :gitlab_duo)
        else all
        end
      end
      def self.find_external_session(namespace_id:, session_id:)
        glab_external.find_by(namespace_id: namespace_id, id: session_id)
      end

      def self.find_by_external_xid(namespace_id:, external_xid:, user_id:)
        glab_external.find_by(namespace_id: namespace_id, external_xid: external_xid, user_id: user_id)
      end

      # Scopes for `Gitlab::Pagination::Keyset::InOperatorOptimization::QueryBuilder`, backed by
      # i_ai_governance_sessions_on_namespace_started_at_id.
      scope :in_optimization_array_mapping_scope, ->(namespace_id_expression) {
        where(arel_table[:namespace_id].eq(namespace_id_expression))
      }
      scope :in_optimization_finder_query, ->(_session_started_at_expression, id_expression) {
        where(arel_table[:id].eq(id_expression))
      }
      scope :for_flow_type, ->(flow_type) { where(flow_type: flow_type) }
      # flow_type is nullable, and `WHERE flow_type != X` would silently drop the NULL rows.
      scope :excluding_flow_type, ->(flow_type) { where(flow_type: nil).or(where.not(flow_type: flow_type)) }
      scope :excluding_project, ->(project_id) { where(project_id: nil).or(where.not(project_id: project_id)) }
      scope :excluding_user, ->(user_id) { where.not(user_id: user_id) }
      scope :for_session_started_after, ->(time) { where(arel_table[:session_started_at].gteq(time)) }
      scope :for_session_started_before, ->(time) { where(arel_table[:session_started_at].lteq(time)) }
      # Invoker-private Duo sessions (for example started from a Slack DM) are hidden from
      # listings, as with duo_workflow_session_artifacts. The check is one primary key lookup
      # per candidate row; rows without a workflow_id always pass.
      scope :without_private_messaging_sessions, -> {
        private_keys = ::Ai::Messaging::AdapterRegistry.private_to_invoker_keys
        next all if private_keys.empty?

        private_workflow = ::Ai::DuoWorkflows::Workflow
          .where(::Ai::DuoWorkflows::Workflow.arel_table[:id].eq(arel_table[:workflow_id]))
          .where("(duo_workflows_workflows.messaging_callback_context ->> 'adapter') IN (?)", private_keys)

        where(private_workflow.arel.exists.not)
      }
      # `preload` so the associations survive the `FROM (subquery)` rewrite done by the
      # in-operator optimization.
      scope :preload_for_list, -> {
        preload(:user, namespace: :route, project: [:route, { namespace: :route }])
      }
      scope :order_by_session_started_at_and_id_desc, -> {
        order(
          ::Gitlab::Pagination::Keyset::Order.build(
            [
              ::Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
                attribute_name: 'session_started_at',
                order_expression: arel_table[:session_started_at].desc,
                nullable: :not_nullable
              ),
              ::Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
                attribute_name: 'id',
                order_expression: arel_table[:id].desc,
                nullable: :not_nullable
              )
            ]
          )
        )
      }
    end
  end
end
