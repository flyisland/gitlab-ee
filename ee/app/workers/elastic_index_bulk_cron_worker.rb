# frozen_string_literal: true

class ElasticIndexBulkCronWorker # rubocop:disable Scalability/IdempotentWorker -- cron worker
  include Elastic::BulkCronWorker

  worker_resource_boundary :cpu
  urgency :low
  # Must read from primary: refs are queued via Redis (no Sidekiq LSN), so `:sticky` reads
  # from lagged replicas and indexes stale rows.
  data_consistency :always

  private

  def service
    Elastic::ProcessBookkeepingService.new
  end
end
