# frozen_string_literal: true

module Ai
  module DuoWorkflows
    # Scans duo_workflows_workflows for sessions currently in a billable status and
    # fans out per-namespace fetches of their credit totals from CustomersDot.
    #
    # Current status, not "ever reached a billable status": a session that billed and
    # then dropped to `failed` before its billable second was scanned is missed and
    # reads null. Accepted for 19.4; scanning `failed` is a tracked follow-up.
    class FetchSessionCreditsCronWorker
      include ApplicationWorker
      # The SyncCursor advance is a ClickHouse insert, so this worker registers for
      # migration pause control like its child.
      include ClickHouseWorker
      # Disables retries: a retried run could overlap the next 15-minute tick and
      # double-read the cursor. A dropped cycle just widens the next scan window.
      include ::CronjobQueue

      idempotent!
      # :until_executing releases as soon as a run starts; :until_executed drops a
      # tick that would overlap a still-running one.
      deduplicate :until_executed
      # :delayed depends on the retry mechanism CronjobQueue disables. Replica lag
      # cannot matter anyway: the scan only reads rows older than SETTLE_HORIZON.
      data_consistency :sticky
      feature_category :duo_agent_platform
      urgency :low
      tags :clickhouse
      # Credits are never urgent; on a degraded table skip the cycle. The cursor only
      # advances on a dispatch, so the next run picks the same rows up. Dispatched
      # batches that fail later are recovered by the child worker's Sidekiq retries.
      defer_on_database_health_signal :gitlab_main_org, [:duo_workflows_workflows]

      SYNC_CURSOR = :duo_workflow_session_credits
      # Grace period for AI Gateway's billing events to land in CustomersDot before a
      # session's transition is scanned.
      SETTLE_HORIZON = 2.hours
      MAX_ROWS_PER_RUN = 10_000
      MAX_IDS_PER_JOB = 100

      def perform
        return unless ::Gitlab::ClickHouse.globally_enabled_for_analytics?

        rows = scan
        return if rows.empty?

        # Nothing dispatched means the flag is off for every scanned row; hold the
        # cursor so those rows are re-read once it is enabled.
        return unless dispatch(rows)

        ::ClickHouse::SyncCursor.update_cursor_for(SYNC_CURSOR, rows.last.updated_at.to_i)
      end

      private

      # A group gate or the global toggle both satisfy the group actor check.
      # Self-managed batches carry no namespace, so only the instance toggle applies.
      def ingestion_enabled_for?(root_namespace_id)
        return Feature.enabled?(:duo_workflow_session_credits_ingestion, :instance) unless root_namespace_id

        Feature.enabled?(:duo_workflow_session_credits_ingestion, ::Group.actor_from_id(root_namespace_id))
      end

      def saas?
        ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
      end

      # `> cursor_time`, not `>= cursor_time + 1.second`: the cursor stores whole
      # epoch seconds, so the high-water second is re-read next run. Re-fetching is an
      # upsert and the safe direction to round; skipping would drop rows that
      # MAX_ROWS_PER_RUN truncated mid-second. Known limit: a single second holding
      # more than MAX_ROWS_PER_RUN rows cannot be crossed (a composite cursor with an
      # id tiebreak is a tracked follow-up).
      #
      # rubocop:disable CodeReuse/ActiveRecord -- the bounded window and keyset order
      # ride idx_workflows_status_updated_at_id, this worker's scan strategy.
      def scan
        ::Ai::DuoWorkflows::Workflow
          .with_billable_status
          .where(::Ai::DuoWorkflows::Workflow.arel_table[:updated_at].gt(cursor_time))
          .where(updated_at: ..SETTLE_HORIZON.ago)
          .order(:updated_at, :id)
          .limit(MAX_ROWS_PER_RUN)
          .select(:id, :namespace_id, :project_id, :updated_at)
          .to_a
      end
      # rubocop:enable CodeReuse/ActiveRecord

      # Floored at the credit window: an unset cursor reads as epoch 0, and windows
      # older than MAX_WINDOW_DAYS cannot overlap the update that queued them.
      def cursor_time
        cursor = ::ClickHouse::SyncCursor.cursor_for(SYNC_CURSOR)
        floor = SessionCredits::IngestService::MAX_WINDOW_DAYS.days.ago.to_i

        Time.zone.at([cursor, floor].max)
      end

      # Returns true when at least one batch was enqueued.
      def dispatch(rows)
        unless saas?
          return false unless ingestion_enabled_for?(nil)

          # Self-managed has one instance-level subscription keyed by license.
          rows.each_slice(MAX_IDS_PER_JOB) do |slice|
            FetchNamespaceSessionCreditsWorker.perform_async(nil, slice.map(&:id))
          end

          return true
        end

        roots = root_namespace_ids_for(rows)

        unresolved_count = rows.count { |row| roots[row.id].nil? }
        log_unresolved(unresolved_count) if unresolved_count > 0

        dispatched = false

        rows.group_by { |row| roots[row.id] }.each do |root_namespace_id, group|
          next unless root_namespace_id
          next unless ingestion_enabled_for?(root_namespace_id)

          group.each_slice(MAX_IDS_PER_JOB) do |slice|
            FetchNamespaceSessionCreditsWorker.perform_async(root_namespace_id, slice.map(&:id))
            dispatched = true
          end
        end

        dispatched
      end

      # Sessions are scoped to EITHER a namespace or a project, and namespace_id may
      # be a subgroup while CustomersDot subscriptions are keyed at the root. Two
      # id-keyed plucks instead of one root_ancestor call per row.
      #
      # rubocop:disable CodeReuse/ActiveRecord -- see scan
      def root_namespace_ids_for(rows)
        project_ids = rows.filter_map(&:project_id).uniq
        project_namespaces = ::Project.id_in(project_ids).pluck(:id, :namespace_id).to_h

        namespace_ids = (rows.filter_map(&:namespace_id) + project_namespaces.values).uniq
        roots = ::Namespace.id_in(namespace_ids).pluck(:id, Arel.sql('traversal_ids[1]')).to_h

        rows.each_with_object({}) do |row, hash|
          namespace_id = row.namespace_id || project_namespaces[row.project_id]
          hash[row.id] = roots[namespace_id]
        end
      end
      # rubocop:enable CodeReuse/ActiveRecord

      # An unresolvable root (deleted namespace or project, empty traversal_ids) drops
      # the row while the cursor advances past it; without this the loss is invisible.
      def log_unresolved(count)
        ::Gitlab::AppLogger.warn(
          Labkit::Fields::CLASS_NAME => self.class.name,
          Labkit::Fields::LOG_MESSAGE => 'Skipped sessions with an unresolvable root namespace',
          :unresolved_count => count
        )
      end
    end
  end
end
