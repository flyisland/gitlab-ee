# frozen_string_literal: true

module Geo
  class CiJobArtifactVerificationSummaryCalculatorWorker
    include ApplicationWorker
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext -- This worker does not perform work scoped to a context

    MAX_RUNTIME = 3.minutes

    idempotent!
    deduplicate :until_executed, ttl: MAX_RUNTIME

    data_consistency :sticky

    feature_category :geo_replication

    def perform
      return unless Gitlab::Geo.enabled?
      return unless Feature.enabled?(:geo_job_artifact_verification_summaries) # rubocop:disable Gitlab/FeatureFlagWithoutActor -- Geo infrastructure, not scoped to an actor

      runtime_limiter = Gitlab::Metrics::RuntimeLimiter.new(MAX_RUNTIME)
      service = CiJobArtifactVerificationSummaryCalculatorService.new

      loop do
        result = service.execute
        break if result[:buckets_calculated] < CiJobArtifactVerificationSummaryCalculatorService::DIRTY_BUCKET_LIMIT
        break if runtime_limiter.over_time?
      end
    end
  end
end
