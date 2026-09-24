# frozen_string_literal: true

module Sbom
  class IngestReportsWorker
    include ApplicationWorker

    deduplicate :until_executed, if_deduplicated: :reschedule_once
    idempotent!

    data_consistency :always

    worker_resource_boundary :cpu
    queue_namespace :sbom_reports
    feature_category :dependency_management

    defer_on_database_health_signal :gitlab_sec, [::Sbom::Occurrence.table_name], 1.minute

    def self.defer_on_database_health_signal?
      # rubocop:disable Gitlab/FeatureFlagWithoutActor -- fleet-wide throttle, no actor in scope
      Feature.enabled?(:defer_sbom_ingest_reports_on_database_health)
      # rubocop:enable Gitlab/FeatureFlagWithoutActor
    end

    def perform(pipeline_id)
      ::Ci::Pipeline.find_by_id(pipeline_id).try do |pipeline|
        ::Sbom::Ingestion::IngestReportsService.execute(pipeline)
      end
    end
  end
end
