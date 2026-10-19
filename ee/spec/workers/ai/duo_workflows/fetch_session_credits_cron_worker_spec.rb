# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::FetchSessionCreditsCronWorker, :click_house, :clean_gitlab_redis_shared_state,
  feature_category: :duo_agent_platform do
  let_it_be(:root_group) { create(:group) }
  # A missing cursor is the cold-start path (seeds and returns). Everything else
  # exercises a warm cursor older than the credit window so the floor applies.
  let(:warm_cursor) { true }
  let_it_be(:subgroup) { create(:group, parent: root_group) }
  let_it_be(:project) { create(:project, group: root_group) }

  let(:child_worker) { Ai::DuoWorkflows::FetchNamespaceSessionCreditsWorker }

  subject(:perform) { described_class.new.perform }

  before do
    stub_feature_flags(duo_workflow_session_credits_ingestion: true)
    allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)
    allow(Gitlab::Saas).to receive(:feature_available?).with(:gitlab_com_subscriptions).and_return(true)

    ClickHouse::SyncCursor.update_cursor_for(described_class::SYNC_CURSOR, 100.days.ago.to_i) if warm_cursor
  end

  def create_billable(attrs)
    create(:duo_workflows_workflow, **{ status: 3, updated_at: 3.hours.ago }.merge(attrs))
  end

  it 'dispatches a child job keyed by root namespace' do
    workflow = create_billable(namespace: subgroup)

    expect(child_worker).to receive(:bulk_perform_async).with([[root_group.id, [workflow.id]]])

    perform
  end

  it 'resolves the root namespace for project-scoped sessions' do
    workflow = create_billable(namespace: nil, project: project)

    expect(child_worker).to receive(:bulk_perform_async).with([[root_group.id, [workflow.id]]])

    perform
  end

  it 'skips sessions inside the settle horizon' do
    create_billable(namespace: root_group, updated_at: 30.minutes.ago)

    expect(child_worker).not_to receive(:bulk_perform_async)

    perform
  end

  it 'skips non-billable sessions' do
    create_billable(namespace: root_group, status: 4)

    expect(child_worker).not_to receive(:bulk_perform_async)

    perform
  end

  it 'keeps the oldest rows across statuses when the per-run cap truncates a scan' do
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 2)
    # Pin to one batch: the per-tick loop would otherwise keep walking and dispatch
    # the third row too, since nothing else in this example bounds it. The loop's
    # own multi-batch behaviour has its own examples below.
    stub_const("#{described_class}::MAX_BATCHES_PER_RUN", 1)
    base = 3.hours.ago.change(usec: 0)
    finished_old = create_billable(namespace: root_group, status: 3, updated_at: base)
    stopped_mid = create_billable(namespace: root_group, status: 5, updated_at: base + 1.second)
    create_billable(namespace: root_group, status: 3, updated_at: base + 2.seconds)

    dispatched = []
    allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

    perform

    expect(dispatched).to contain_exactly(finished_old.id, stopped_mid.id)
    expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
      .to eq(stopped_mid.reload.updated_at.to_i)
  end

  it 'registers with ClickHouse migration pause control and disables retries' do
    expect(described_class.click_house_worker_attrs).to be_present
    expect(described_class.sidekiq_options['retry']).to be(false)
    expect(described_class.get_data_consistency_per_database.values.uniq).to eq([:sticky])
  end

  it 'floors the scan at the credit window' do
    create_billable(namespace: root_group, updated_at: 91.days.ago)
    fresh = create_billable(namespace: root_group)

    expect(child_worker).to receive(:bulk_perform_async).with([[root_group.id, [fresh.id]]])

    perform
  end

  # A `status IN (...)` list cannot ride idx_workflows_status_updated_at_id for the
  # (updated_at, id) ordering, so Postgres sorts the whole window before applying the
  # limit and the scan times out as the window grows.
  it 'scans one status at a time so the index can satisfy the ordering' do
    create_billable(namespace: root_group)
    allow(child_worker).to receive(:perform_async)

    recorder = ActiveRecord::QueryRecorder.new { perform }
    scan_sql = recorder.log.find { |sql| sql.include?('duo_workflows_workflows') && sql.include?('UNION ALL') }

    expect(scan_sql).to be_present
    expect(scan_sql).not_to match(/"status" IN/)
    expect(scan_sql.scan(/"status" = \d+/).size)
      .to eq(Ai::DuoWorkflows::Workflow::BILLABLE_STATUSES.size)
  end

  # Resolving the bounds per branch put each status on a window microseconds apart, so a row
  # near a boundary could land inside one status's window and outside another's.
  it 'gives every branch the same window bounds', :aggregate_failures do
    create_billable(namespace: root_group)
    allow(child_worker).to receive(:perform_async)

    recorder = ActiveRecord::QueryRecorder.new { perform }
    scan_sql = recorder.log.find { |sql| sql.include?('duo_workflows_workflows') && sql.include?('UNION ALL') }

    expect(scan_sql.scan(/"updated_at" >= '([^']+)'/).flatten.uniq.size).to eq(1)
    expect(scan_sql.scan(/"updated_at" <= '([^']+)'/).flatten.uniq.size).to eq(1)
  end

  it 'advances the cursor to the newest dispatched row' do
    workflow = create_billable(namespace: root_group)
    allow(child_worker).to receive(:bulk_perform_async)

    perform

    expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
      .to eq(workflow.reload.updated_at.to_i)
  end

  it 'does not touch the cursor when nothing was scanned' do
    expect { perform }.not_to change { ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR) }
  end

  it 'records how many child jobs a run enqueued' do
    create_billable(namespace: root_group)
    allow(child_worker).to receive(:bulk_perform_async)
    worker = described_class.new

    worker.perform

    expect(worker.logging_extras).to include(
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.dispatched_jobs' => 1
    )
  end

  it 'rescans a row sharing its clock second with the cursor high-water mark' do
    second = 3.hours.ago.change(usec: 0)
    earlier = create_billable(namespace: root_group, updated_at: second - 1.second)
    at_cursor = create_billable(namespace: root_group, updated_at: second.change(usec: 200_000))
    truncated = create_billable(namespace: root_group, updated_at: second.change(usec: 900_000))

    # The first run fills up mid-second: it takes `earlier` and `at_cursor`, leaving
    # `truncated` behind even though it is inside the window. The cursor can only record
    # the second, so the second run has to re-enter that second to reach it. One batch per
    # run, otherwise the in-tick keyset would reach `truncated` without crossing a tick.
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 2)
    stub_const("#{described_class}::MAX_BATCHES_PER_RUN", 1)

    dispatched = []
    allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

    described_class.new.perform
    expect(dispatched).to contain_exactly(earlier.id, at_cursor.id)

    described_class.new.perform
    expect(dispatched).to include(truncated.id)
  end

  it 'rescans rows stamped exactly on the cursor second, which a strict comparison would skip' do
    second = 3.hours.ago.change(usec: 0)
    earlier = create_billable(namespace: root_group, updated_at: second - 1.second)
    on_the_second = create_billable(namespace: root_group, updated_at: second)
    also_on_the_second = create_billable(namespace: root_group, updated_at: second)
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 2)
    stub_const("#{described_class}::MAX_BATCHES_PER_RUN", 1)

    dispatched = []
    allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

    described_class.new.perform
    expect(dispatched).to contain_exactly(earlier.id, on_the_second.id)

    described_class.new.perform
    expect(dispatched).to include(also_on_the_second.id)
  end

  it 'logs the count of sessions whose root namespace cannot be resolved' do
    orphaned = create(:group, parent: root_group)
    create_billable(namespace: orphaned)
    orphaned.update_column(:traversal_ids, [])

    expect(Gitlab::AppLogger).to receive(:warn).with(hash_including(unresolved_count: 1))
    expect(child_worker).not_to receive(:bulk_perform_async)

    perform
  end

  it 'splits a namespace into batches of at most 100 ids' do
    workflows = create_list(:duo_workflows_workflow, 3, namespace: root_group, status: 3,
      updated_at: 3.hours.ago)
    stub_const("#{described_class}::MAX_IDS_PER_JOB", 2)

    expect(child_worker).to receive(:bulk_perform_async) do |args_list|
      expect(args_list.size).to eq(2)
      expect(args_list.sum { |(_ns, ids)| ids.size }).to eq(3)
    end.once

    perform
    expect(workflows.size).to eq(3)
  end

  it 'enqueues each batch with one bulk push instead of a perform_async loop' do
    workflow = create_billable(namespace: root_group)

    expect(child_worker).to receive(:bulk_perform_async).with([[root_group.id, [workflow.id]]]).once
    expect(child_worker).not_to receive(:perform_async)

    perform
  end

  it 'orders ids inside a job by created_at so the CustomersDot window stays contiguous' do
    newer = create_billable(namespace: root_group, created_at: 1.day.ago)
    older = create_billable(namespace: root_group, created_at: 3.days.ago)

    expect(child_worker).to receive(:bulk_perform_async).with([[root_group.id, [older.id, newer.id]]])

    perform
  end

  it 'stops at the call budget on a row boundary and leaves the rest for the next tick' do
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 2)
    stub_const("#{described_class}::MAX_CALLS_PER_RUN", 3)
    stub_const("#{described_class}::MAX_IDS_PER_JOB", 1)
    base = 3.hours.ago.change(usec: 0)
    rows = Array.new(5) { |i| create_billable(namespace: create(:group), updated_at: base + i.seconds) }
    dispatched = []
    allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

    worker = described_class.new
    worker.perform

    expect(dispatched).to eq(rows.first(3).map(&:id))
    expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR)).to eq(rows[2].reload.updated_at.to_i)
    expect(worker.logging_extras).to include(
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :budget
    )
  end

  it 'walks ineligible rows across several batches in one tick and records exhaustion' do
    stub_feature_flags(duo_workflow_session_credits_ingestion: create(:group)) # enabled for a group with no rows
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 2)
    base = 3.hours.ago.change(usec: 0)
    rows = Array.new(5) { |i| create_billable(namespace: root_group, updated_at: base + i.seconds) }

    expect(child_worker).not_to receive(:bulk_perform_async)

    worker = described_class.new
    worker.perform

    expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR)).to eq(rows.last.reload.updated_at.to_i)
    expect(worker.logging_extras).to include(
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.batches' => 3,
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.scanned_rows' => 5,
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.dispatched_jobs' => 0,
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :exhausted
    )
  end

  it 'stops after MAX_BATCHES_PER_RUN batches' do
    stub_feature_flags(duo_workflow_session_credits_ingestion: create(:group))
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 2)
    stub_const("#{described_class}::MAX_BATCHES_PER_RUN", 1)
    base = 3.hours.ago.change(usec: 0)
    rows = Array.new(3) { |i| create_billable(namespace: root_group, updated_at: base + i.seconds) }

    worker = described_class.new
    worker.perform

    expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR)).to eq(rows[1].reload.updated_at.to_i)
    expect(worker.logging_extras).to include(
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :batches
    )
  end

  it 'continues inside a busy second with an exact keyset instead of re-reading dispatched rows' do
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 2)
    base = 3.hours.ago.change(usec: 0)
    rows = Array.new(3) { |i| create_billable(namespace: root_group, updated_at: base + (i * 100).fdiv(1_000_000)) }
    dispatched = []
    allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

    recorder = ActiveRecord::QueryRecorder.new { perform }

    expect(dispatched).to match_array(rows.map(&:id))
    expect(dispatched.size).to eq(3)
    keyset_predicate = /\("duo_workflows_workflows"\."updated_at", "duo_workflows_workflows"\."id"\) > /
    expect(recorder.log.grep(keyset_predicate)).not_to be_empty
    expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR)).to eq(base.to_i)
  end

  it 'reports zero cursor lag once a tick reaches the settle horizon' do
    worker = described_class.new
    worker.perform

    expect(worker.logging_extras).to include(
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :exhausted,
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.cursor_lag_seconds' => 0
    )
  end

  it 'reports how far behind the settle horizon a tick stopped when it did not reach it', :freeze_time do
    stub_const("#{described_class}::MAX_BATCHES_PER_RUN", 1)
    stub_feature_flags(duo_workflow_session_credits_ingestion: create(:group))
    create_billable(namespace: root_group, updated_at: 5.hours.ago)
    create_billable(namespace: root_group, updated_at: 4.hours.ago)

    worker = described_class.new
    worker.perform

    expect(worker.logging_extras).to include(
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :batches,
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.cursor_lag_seconds' => 2.hours.to_i
    )
  end

  context 'on cold start, with no cursor recorded', :freeze_time do
    let(:warm_cursor) { false }

    it 'seeds the cursor at the settle horizon and dispatches nothing' do
      create_billable(namespace: root_group, updated_at: 3.hours.ago)

      expect(child_worker).not_to receive(:bulk_perform_async)
      expect(Gitlab::AppLogger).to receive(:info).with(hash_including(
        Labkit::Fields::LOG_MESSAGE => 'Seeded session credits cursor'
      ))

      perform

      expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
        .to eq(described_class::SETTLE_HORIZON.ago.to_i)
    end

    it 'seeds without scanning, so a cold start never runs the 90-day query' do
      expect(Ai::DuoWorkflows::Workflow).not_to receive(:billable_status_values)

      perform
    end

    it 'seeds even while the flag is off, so the cursor cannot go stale before enablement' do
      stub_feature_flags(duo_workflow_session_credits_ingestion: false)
      create_billable(namespace: root_group)

      perform

      expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
        .to eq(described_class::SETTLE_HORIZON.ago.to_i)
    end

    it 'keeps advancing while the flag is off, so enabling it later starts from now, not from deploy' do
      stub_feature_flags(duo_workflow_session_credits_ingestion: false)
      perform

      travel 15.minutes
      while_off = create_billable(namespace: root_group, updated_at: 2.hours.ago - 5.minutes)
      # A later row moves the high-water second past `while_off`; that last second is
      # re-read next tick by design, earlier seconds never are.
      high_water = create_billable(namespace: root_group, updated_at: 2.hours.ago - 4.minutes)
      described_class.new.perform

      stub_feature_flags(duo_workflow_session_credits_ingestion: true)
      travel 15.minutes
      after_enable = create_billable(namespace: root_group, updated_at: 2.hours.ago - 5.minutes)
      dispatched = []
      allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

      described_class.new.perform

      expect(dispatched).to include(after_enable.id, high_water.id)
      expect(dispatched).not_to include(while_off.id)
    end

    it 'does not backfill sessions older than the seed, but picks up sessions after it' do
      old = create_billable(namespace: root_group, updated_at: 3.hours.ago)
      perform

      travel 15.minutes
      fresh = create_billable(namespace: root_group, updated_at: 2.hours.ago - 5.minutes)
      dispatched = []
      allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

      described_class.new.perform

      expect(dispatched).to eq([fresh.id])
      expect(dispatched).not_to include(old.id)
    end
  end

  it 'splits a namespace where sessions were created more than MAX_CREATED_AT_GAP apart' do
    old = create_billable(namespace: root_group, created_at: 60.days.ago)
    recent_a = create_billable(namespace: root_group, created_at: 2.days.ago)
    recent_b = create_billable(namespace: root_group, created_at: 1.day.ago)

    expect(child_worker).to receive(:bulk_perform_async)
      .with([[root_group.id, [old.id]], [root_group.id, [recent_a.id, recent_b.id]]])

    perform
  end

  context 'when the concurrency limiter is still holding child jobs' do
    let(:limiter) { Gitlab::SidekiqMiddleware::ConcurrencyLimit::ConcurrencyLimitService }

    it 'skips the tick and holds the cursor once the backlog fills the call budget' do
      allow(limiter).to receive(:queue_size).with(child_worker.name).and_return(described_class::MAX_CALLS_PER_RUN)
      create_billable(namespace: root_group)

      expect(child_worker).not_to receive(:bulk_perform_async)

      worker = described_class.new
      expect { worker.perform }.not_to change { ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR) }

      expect(worker.logging_extras).to include(
        'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :backlog,
        'extra.ai_duo_workflows_fetch_session_credits_cron_worker.child_backlog' => described_class::MAX_CALLS_PER_RUN,
        'extra.ai_duo_workflows_fetch_session_credits_cron_worker.dispatched_jobs' => 0
      )
    end

    it 'counts deferred child jobs against the call budget' do
      stub_const("#{described_class}::MAX_CALLS_PER_RUN", 3)
      stub_const("#{described_class}::MAX_IDS_PER_JOB", 1)
      allow(limiter).to receive(:queue_size).with(child_worker.name).and_return(2)
      base = 3.hours.ago.change(usec: 0)
      rows = Array.new(3) { |i| create_billable(namespace: create(:group), updated_at: base + i.seconds) }
      dispatched = []
      allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }

      worker = described_class.new
      worker.perform

      expect(dispatched).to eq([rows.first.id])
      expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR)).to eq(rows.first.reload.updated_at.to_i)
      expect(worker.logging_extras).to include(
        'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :budget
      )
    end
  end

  it 'stops walking when the back-off latch trips between batches' do
    stub_const("#{described_class}::MAX_ROWS_PER_RUN", 1)
    base = 3.hours.ago.change(usec: 0)
    rows = Array.new(3) { |i| create_billable(namespace: root_group, updated_at: base + i.seconds) }
    allow(Ai::DuoWorkflows::SessionCredits::Backoff).to receive(:reason).and_return(nil, :server_error)
    dispatched = []
    allow(child_worker).to receive(:bulk_perform_async) { |args| args.each { |(_ns, ids)| dispatched.concat(ids) } }
    allow(Gitlab::AppLogger).to receive(:warn)

    worker = described_class.new
    worker.perform

    expect(dispatched).to eq([rows.first.id])
    expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR)).to eq(rows.first.reload.updated_at.to_i)
    expect(worker.logging_extras).to include(
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.stop_reason' => :backoff,
      'extra.ai_duo_workflows_fetch_session_credits_cron_worker.batches' => 1
    )
    expect(Gitlab::AppLogger).to have_received(:warn).with(hash_including(
      Labkit::Fields::LOG_MESSAGE => 'Skipping session credits cycle while backing off from CustomersDot'
    ))
  end

  context 'when backing off from CustomersDot' do
    before do
      Ai::DuoWorkflows::SessionCredits::Backoff.trigger!(reason: :server_error)
    end

    it 'skips the cycle without touching the cursor, and warns with the reason' do
      create_billable(namespace: root_group)

      expect(child_worker).not_to receive(:bulk_perform_async)
      expect(Gitlab::AppLogger).to receive(:warn).with(hash_including(
        Labkit::Fields::LOG_MESSAGE => 'Skipping session credits cycle while backing off from CustomersDot',
        Labkit::Fields::ERROR_TYPE => 'server_error'
      ))

      expect { perform }.not_to change { ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR) }
    end
  end

  context 'when the feature flag is off' do
    before do
      stub_feature_flags(duo_workflow_session_credits_ingestion: false)
    end

    it 'dispatches nothing but still advances the cursor' do
      workflow = create_billable(namespace: root_group)

      expect(child_worker).not_to receive(:bulk_perform_async)

      perform

      expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
        .to eq(workflow.reload.updated_at.to_i)
    end
  end

  context 'when the feature flag is enabled for a group only' do
    let_it_be(:other_group) { create(:group) }

    before do
      stub_feature_flags(duo_workflow_session_credits_ingestion: root_group)
    end

    it 'dispatches only sessions rooted in the enabled group' do
      enabled = create_billable(namespace: subgroup)
      create_billable(namespace: other_group)

      expect(child_worker).to receive(:bulk_perform_async).with([[root_group.id, [enabled.id]]]).once

      perform
    end

    it 'advances the cursor past the scanned rows' do
      workflow = create_billable(namespace: root_group)
      allow(child_worker).to receive(:bulk_perform_async)

      perform

      expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
        .to eq(workflow.reload.updated_at.to_i)
    end

    it 'advances the cursor past a batch with only non-gated sessions, so a pilot cannot stall' do
      workflow = create_billable(namespace: other_group)

      expect(child_worker).not_to receive(:bulk_perform_async)

      perform

      expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
        .to eq(workflow.reload.updated_at.to_i)
    end

    context 'when not on .com' do
      before do
        allow(Gitlab::Saas).to receive(:feature_available?).with(:gitlab_com_subscriptions).and_return(false)
      end

      it 'dispatches nothing, since self-managed has no group to scope to, but still advances the cursor' do
        workflow = create_billable(namespace: root_group)

        expect(child_worker).not_to receive(:bulk_perform_async)

        perform

        expect(ClickHouse::SyncCursor.cursor_for(described_class::SYNC_CURSOR))
          .to eq(workflow.reload.updated_at.to_i)
      end
    end
  end

  context 'when ClickHouse analytics is disabled' do
    before do
      allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
    end

    it 'is a no-op' do
      create_billable(namespace: root_group)

      expect(child_worker).not_to receive(:bulk_perform_async)

      perform
    end
  end

  context 'when not on .com' do
    before do
      allow(Gitlab::Saas).to receive(:feature_available?).with(:gitlab_com_subscriptions).and_return(false)
    end

    it 'dispatches one instance-level batch with no namespace' do
      workflow = create_billable(namespace: root_group)

      expect(child_worker).to receive(:bulk_perform_async).with([[nil, [workflow.id]]])

      perform
    end
  end
end
