# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::BackfillCiFinishedBuildsToClickHouse, feature_category: :fleet_visibility do
  let(:connection) { Ci::ApplicationRecord.connection }
  let(:builds) { table(:p_ci_builds, database: :ci, primary_key: :id) }
  let(:sync_events) { table(:p_ci_finished_build_ch_sync_events, database: :ci) }
  let(:pipelines) { table(:p_ci_pipelines, database: :ci, primary_key: :id) }

  let(:default_attributes) { { project_id: 500, partition_id: 100 } }
  let!(:pipeline) { pipelines.create!(default_attributes) }

  subject(:perform_migration) { described_class.new(**migration_attrs).perform }

  before do
    allow(::Gitlab::ClickHouse).to receive(:configured?).and_return(true)
  end

  context 'when processing finished builds' do
    let!(:successful_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'success',
          finished_at: 10.days.ago,
          updated_at: 10.days.ago
        )
      )
    end

    let!(:failed_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'failed',
          finished_at: 5.days.ago,
          updated_at: 5.days.ago
        )
      )
    end

    let!(:canceled_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'canceled',
          finished_at: 3.days.ago,
          updated_at: 3.days.ago
        )
      )
    end

    let!(:running_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'running',
          finished_at: nil,
          updated_at: 1.day.ago
        )
      )
    end

    let!(:pending_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'pending',
          finished_at: nil,
          updated_at: 1.day.ago
        )
      )
    end

    let!(:bridge) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Bridge',
          status: 'success',
          finished_at: 2.days.ago,
          updated_at: 2.days.ago
        )
      )
    end

    let(:migration_attrs) do
      {
        start_id: successful_build.id,
        end_id: bridge.id,
        batch_table: :p_ci_builds,
        batch_column: :id,
        sub_batch_size: 100,
        pause_ms: 0,
        connection: connection,
        job_arguments: []
      }
    end

    it 'creates sync events for successful builds' do
      perform_migration

      sync_event = sync_events.find_by(build_id: successful_build.id)
      expect(sync_event).to be_present
      expect(sync_event.project_id).to eq(default_attributes[:project_id])
      expect(sync_event.processed).to be false
    end

    it 'creates sync events for failed builds' do
      perform_migration

      expect(sync_events.find_by(build_id: failed_build.id)).to be_present
    end

    it 'creates sync events for canceled builds' do
      perform_migration

      expect(sync_events.find_by(build_id: canceled_build.id)).to be_present
    end

    it 'does not create sync events for running builds' do
      perform_migration

      expect(sync_events.find_by(build_id: running_build.id)).to be_nil
    end

    it 'does not create sync events for pending builds' do
      perform_migration

      expect(sync_events.find_by(build_id: pending_build.id)).to be_nil
    end

    it 'does not create sync events for bridges' do
      perform_migration

      expect(sync_events.find_by(build_id: bridge.id)).to be_nil
    end

    it 'creates the correct number of sync events' do
      expect { perform_migration }.to change { sync_events.count }.by(3)
    end

    context 'when ClickHouse is not configured' do
      before do
        allow(::Gitlab::ClickHouse).to receive(:configured?).and_return(false)
      end

      it 'does not create any sync events' do
        expect { perform_migration }.not_to change { sync_events.count }
      end
    end
  end

  context 'when no matching builds exist in the batch' do
    let!(:running_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'running',
          finished_at: nil,
          updated_at: 1.day.ago
        )
      )
    end

    let!(:bridge) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Bridge',
          status: 'success',
          finished_at: 2.days.ago,
          updated_at: 2.days.ago
        )
      )
    end

    let(:migration_attrs) do
      {
        start_id: running_build.id,
        end_id: bridge.id,
        batch_table: :p_ci_builds,
        batch_column: :id,
        sub_batch_size: 100,
        pause_ms: 0,
        connection: connection,
        job_arguments: []
      }
    end

    it 'does not create any sync events' do
      expect { perform_migration }.not_to change { sync_events.count }
    end
  end

  context 'when build finished_at is older than 180 days' do
    let!(:old_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'success',
          finished_at: 200.days.ago,
          updated_at: 200.days.ago
        )
      )
    end

    let!(:recent_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'success',
          finished_at: 10.days.ago,
          updated_at: 10.days.ago
        )
      )
    end

    let(:migration_attrs) do
      {
        start_id: old_build.id,
        end_id: recent_build.id,
        batch_table: :p_ci_builds,
        batch_column: :id,
        sub_batch_size: 100,
        pause_ms: 0,
        connection: connection,
        job_arguments: []
      }
    end

    it 'skips builds with finished_at older than 180 days' do
      perform_migration

      expect(sync_events.find_by(build_id: old_build.id)).to be_nil
    end

    it 'creates sync events for builds within 180 days' do
      perform_migration

      expect(sync_events.find_by(build_id: recent_build.id)).to be_present
    end
  end

  context 'when sync event already exists' do
    let!(:finished_build) do
      builds.create!(
        default_attributes.merge(
          commit_id: pipeline.id,
          type: 'Ci::Build',
          status: 'success',
          finished_at: 10.days.ago,
          updated_at: 10.days.ago
        )
      )
    end

    let!(:existing_sync_event) do
      sync_events.create!(
        build_id: finished_build.id,
        project_id: default_attributes[:project_id],
        build_finished_at: finished_build.finished_at,
        processed: true
      )
    end

    let(:migration_attrs) do
      {
        start_id: finished_build.id,
        end_id: finished_build.id,
        batch_table: :p_ci_builds,
        batch_column: :id,
        sub_batch_size: 100,
        pause_ms: 0,
        connection: connection,
        job_arguments: []
      }
    end

    it 'upserts the sync event and resets processed to false' do
      expect { perform_migration }.not_to change { sync_events.count }

      sync_event = sync_events.find_by(build_id: finished_build.id)
      expect(sync_event.processed).to be false
    end
  end
end
