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
      # Credits are never urgent; on a degraded table skip the cycle. A deferred run
      # does not scan, so the cursor stays put and the next run picks the same rows up.
      # Dispatched batches that fail later are recovered by the child worker's retries.
      defer_on_database_health_signal :gitlab_main_org, [:duo_workflows_workflows]

      SYNC_CURSOR = :duo_workflow_session_credits
      # Grace period for AI Gateway's billing events to land in CustomersDot before a
      # session's transition is scanned.
      SETTLE_HORIZON = 2.hours
      # Rows per batch. Also what the runbook's console check reads, so keep the value.
      MAX_ROWS_PER_RUN = 1_000
      # Batches per tick. Rows outside the rollout gate cost only the scan, so a stale
      # cursor drains at up to MAX_BATCHES_PER_RUN batches a tick while dispatch stays
      # budgeted; at a global rollout the budget is spent within a batch or two.
      MAX_BATCHES_PER_RUN = 10
      # CustomersDot calls (child jobs of <= MAX_IDS_PER_JOB ids) outstanding per tick: the
      # worst case Fulfillment acked. Jobs the concurrency limiter is still holding count
      # against it, so a slow CustomersDot shrinks dispatch instead of growing that queue.
      # A batch of n rows yields at most n jobs, so scanning at most the remaining budget
      # keeps the bound strict without skipping any row.
      MAX_CALLS_PER_RUN = 1_000
      MAX_IDS_PER_JOB = 100
      # A lone long-lived session would otherwise widen the CustomersDot window of the 99
      # sessions sliced with it; a gap this wide gets its own job.
      MAX_CREATED_AT_GAP = 7.days

      def perform
        return unless ::Gitlab::ClickHouse.globally_enabled_for_analytics?
        return seed_cursor if cursor == 0

        walk
      end

      private

      def walk
        backlog = child_backlog
        budget = [MAX_CALLS_PER_RUN - backlog, 0].max
        remaining = budget
        last = nil
        batches = 0
        scanned = 0
        stop_reason = remaining > 0 ? :batches : :backlog

        MAX_BATCHES_PER_RUN.times do
          break if remaining <= 0

          # Re-read per batch: children from the first batch answer within seconds, and a
          # latch they trip must stop the walk, not just the next tick.
          backoff_reason = SessionCredits::Backoff.reason
          if backoff_reason
            log_backoff(backoff_reason)
            stop_reason = :backoff
            break
          end

          rows = scan(after: last, limit: [remaining, MAX_ROWS_PER_RUN].min)

          if rows.empty?
            stop_reason = :exhausted
            break
          end

          remaining -= dispatch(rows)
          last = rows.last
          ::ClickHouse::SyncCursor.update_cursor_for(SYNC_CURSOR, last.updated_at.to_i)
          batches += 1
          scanned += rows.size

          if remaining <= 0
            stop_reason = :budget
            break
          end
        end

        log_extra_metadata_on_done(:batches, batches)
        log_extra_metadata_on_done(:scanned_rows, scanned)
        log_extra_metadata_on_done(:eligible_rows, @eligible_rows.to_i)
        log_extra_metadata_on_done(:dispatched_jobs, budget - remaining)
        log_extra_metadata_on_done(:child_backlog, backlog)
        log_extra_metadata_on_done(:stop_reason, stop_reason)
        # Seconds of window still unread: 0 once the tick reached the settle horizon. Floored
        # like the scan, so a rewind below the window does not read as years behind.
        lag_from = last ? last.updated_at.to_i : cursor_time.to_i
        lag = stop_reason == :exhausted ? 0 : [SETTLE_HORIZON.ago.to_i - lag_from, 0].max
        log_extra_metadata_on_done(:cursor_lag_seconds, lag)
      end

      # Child jobs the concurrency limiter has deferred. One LLEN on the limiter's list.
      def child_backlog
        ::Gitlab::SidekiqMiddleware::ConcurrencyLimit::ConcurrencyLimitService
          .queue_size(FetchNamespaceSessionCreditsWorker.name)
      end

      # A group gate or the global toggle both satisfy the group actor check.
      # Self-managed batches carry no namespace, so only the instance toggle applies.
      def ingestion_enabled_for?(root_namespace_id)
        return Feature.enabled?(:duo_workflow_session_credits_ingestion, :instance) unless root_namespace_id

        Feature.enabled?(:duo_workflow_session_credits_ingestion, ::Group.actor_from_id(root_namespace_id))
      end

      def saas?
        ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
      end

      # `>= cursor_time`: the cursor stores whole epoch seconds, so the next tick re-reads
      # the high-water second, including rows at exactly .000000 that `>` would skip.
      # Re-fetching is an upsert and the safe direction to round; skipping would drop rows
      # that a batch truncated mid-second. Known limit: a single second holding more than
      # MAX_ROWS_PER_RUN rows cannot be crossed between ticks (a composite cursor with an
      # id tiebreak is a tracked follow-up).
      #
      # One branch per billable status, not `status IN (...)`: idx_workflows_status_updated_at_id
      # leads on status, so an IN list leaves Postgres unable to emit rows in (updated_at, id)
      # order and it sorted every row in the window before the LIMIT, which timed out once
      # the cursor lagged. Equality on the leading column gives one ordered index scan per
      # status, merged by MergeAppend. Inside a tick, later batches continue from the exact
      # (updated_at, id) of the last consumed row, so a busy second cannot stall a tick.
      #
      # `limit` is the remaining call budget capped at MAX_ROWS_PER_RUN: one job per
      # <= MAX_IDS_PER_JOB ids means jobs <= rows, so the budget cannot overshoot and the
      # cursor still stops at a row boundary.
      #
      # rubocop:disable CodeReuse/ActiveRecord -- the bounded window and keyset order
      # ride idx_workflows_status_updated_at_id, this worker's scan strategy.
      def scan(after: nil, limit: MAX_ROWS_PER_RUN)
        # Both bounds are resolved once and shared by every branch, so no row can sit inside
        # one status's window and outside another's.
        lower = after ? nil : cursor_time
        upper = SETTLE_HORIZON.ago

        ::Ai::DuoWorkflows::Workflow
          .from_union(scan_branches(after, lower, upper, limit), remove_duplicates: false, remove_order: false)
          .order(:updated_at, :id)
          .limit(limit)
          .to_a
      end

      # Each branch is limited too: the global first `limit` rows are always within each
      # status's own first `limit`, so this bounds a branch even if the planner stops
      # streaming the merge lazily.
      def scan_branches(after, lower, upper, limit)
        ::Ai::DuoWorkflows::Workflow.billable_status_values.map do |status|
          branch = ::Ai::DuoWorkflows::Workflow
            .where(status: status)
            .where(updated_at: ..upper)
            .order(:updated_at, :id)
            .limit(limit)
            .select(:id, :namespace_id, :project_id, :updated_at, :created_at)

          if after
            branch.where(
              '("duo_workflows_workflows"."updated_at", "duo_workflows_workflows"."id") > (?, ?)',
              after.updated_at, after.id
            )
          else
            branch.where(::Ai::DuoWorkflows::Workflow.arel_table[:updated_at].gteq(lower))
          end
        end
      end
      # rubocop:enable CodeReuse/ActiveRecord

      def cursor
        @cursor ||= ::ClickHouse::SyncCursor.cursor_for(SYNC_CURSOR)
      end

      # Floored at the credit window: windows older than MAX_WINDOW_DAYS cannot
      # overlap the update that queued them.
      def cursor_time
        floor = SessionCredits::IngestService::MAX_WINDOW_DAYS.days.ago.to_i

        Time.zone.at([cursor, floor].max)
      end

      # A missing cursor used to read as epoch 0 and the first run scanned the whole
      # 90-day window (INC-13873). Now the first run only records where "now" is,
      # before any scan; ingestion starts with the next tick. Backfilling older
      # sessions is a deliberate console step: set the cursor to any non-zero epoch
      # second to resume from (floored at MAX_WINDOW_DAYS; 0 would only re-seed).
      def seed_cursor
        seed = SETTLE_HORIZON.ago.to_i
        ::ClickHouse::SyncCursor.update_cursor_for(SYNC_CURSOR, seed)

        ::Gitlab::AppLogger.info(
          Labkit::Fields::CLASS_NAME => self.class.name,
          Labkit::Fields::LOG_MESSAGE => 'Seeded session credits cursor'
        )
      end

      # Warn, not info: a latch that never clears means CustomersDot is down or the
      # kill switch is on, and either needs a human.
      def log_backoff(reason)
        ::Gitlab::AppLogger.warn(
          Labkit::Fields::CLASS_NAME => self.class.name,
          Labkit::Fields::LOG_MESSAGE => 'Skipping session credits cycle while backing off from CustomersDot',
          Labkit::Fields::ERROR_TYPE => reason.to_s
        )
      end

      # Returns the number of child jobs enqueued, one CustomersDot call each.
      def dispatch(rows)
        args_list = saas? ? saas_jobs(rows) : self_managed_jobs(rows)
        @eligible_rows = @eligible_rows.to_i + args_list.sum { |(_, ids)| ids.size }
        return 0 if args_list.empty?

        # rubocop:disable Scalability/BulkPerformWithContext -- the child already logs
        # namespace_id and workflow_ids via loggable_arguments 0, 1
        FetchNamespaceSessionCreditsWorker.bulk_perform_async(args_list)
        # rubocop:enable Scalability/BulkPerformWithContext
        args_list.size
      end

      # Self-managed has one instance-level subscription keyed by license.
      def self_managed_jobs(rows)
        return [] unless ingestion_enabled_for?(nil)

        jobs_for(nil, rows)
      end

      def saas_jobs(rows)
        roots = root_namespace_ids_for(rows)

        unresolved_count = rows.count { |row| roots[row.id].nil? }
        log_unresolved(unresolved_count) if unresolved_count > 0

        rows.group_by { |row| roots[row.id] }.flat_map do |root_namespace_id, group|
          next [] unless root_namespace_id && ingestion_enabled_for?(root_namespace_id)

          jobs_for(root_namespace_id, group)
        end
      end

      # Contiguous creation ranges per job keep the CustomersDot window the child derives
      # from the batch narrow for namespaces with many sessions.
      def jobs_for(root_namespace_id, rows)
        rows
          .sort_by { |row| [row.created_at, row.id] }
          .slice_when { |earlier, later| later.created_at - earlier.created_at > MAX_CREATED_AT_GAP }
          .flat_map { |run| run.each_slice(MAX_IDS_PER_JOB).map { |slice| [root_namespace_id, slice.map(&:id)] } }
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
