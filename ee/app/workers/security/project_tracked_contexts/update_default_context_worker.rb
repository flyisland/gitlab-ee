# frozen_string_literal: true

module Security
  module ProjectTrackedContexts
    class UpdateDefaultContextWorker
      include ApplicationWorker

      data_consistency :delayed
      feature_category :vulnerability_management
      idempotent!

      def perform(*); end
    end
  end
end
