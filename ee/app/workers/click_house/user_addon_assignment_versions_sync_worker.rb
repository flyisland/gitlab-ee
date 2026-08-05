# frozen_string_literal: true

module ClickHouse # rubocop:disable Gitlab/BoundedContexts -- Context already present in other files
  class UserAddonAssignmentVersionsSyncWorker
    include ApplicationWorker
    include ClickHouseWorker

    idempotent!
    queue_namespace :cronjob
    data_consistency :delayed
    feature_category :seat_cost_management
    tags :clickhouse

    def perform; end
  end
end
