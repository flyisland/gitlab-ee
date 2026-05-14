# frozen_string_literal: true

module Security
  class CreateDefaultTrackedContextWorker
    include ApplicationWorker

    data_consistency :delayed
    feature_category :vulnerability_management
    idempotent!

    def perform(*); end
  end
end
