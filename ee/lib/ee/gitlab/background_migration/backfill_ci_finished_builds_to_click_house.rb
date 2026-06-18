# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module BackfillCiFinishedBuildsToClickHouse
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        FINISHED_STATUSES = %w[success failed canceled].freeze

        prepended do
          operation_name :backfill_ci_finished_builds_to_click_house
          tables_to_check_for_vacuum :p_ci_finished_build_ch_sync_events
        end

        override :perform
        def perform
          return unless ::Gitlab::ClickHouse.configured?

          each_sub_batch do |sub_batch|
            insert_sync_events(sub_batch)
          end
        end

        private

        def insert_sync_events(sub_batch)
          cutoff_date = 180.days.ago.beginning_of_day

          # Since we batch by id (not finished_at), some records in later batches may have
          # finished_at older than 180 days if the migration runs over an extended period.
          # This filter ensures we only backfill records within the intended time window.
          builds_data = sub_batch
            .where(type: 'Ci::Build')
            .where(status: FINISHED_STATUSES)
            .where.not(finished_at: nil)
            .where(finished_at: cutoff_date..)
            .pluck(:id, :project_id, :finished_at)

          return if builds_data.empty?

          attributes = builds_data.map do |id, project_id, finished_at|
            {
              build_id: id,
              project_id: project_id,
              build_finished_at: finished_at,
              processed: false
            }
          end

          ::Ci::FinishedBuildChSyncEvent.upsert_all(
            attributes,
            unique_by: [:build_id, :partition]
          )
        end
      end
    end
  end
end
