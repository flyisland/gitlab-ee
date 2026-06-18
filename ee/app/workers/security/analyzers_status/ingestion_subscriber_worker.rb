# frozen_string_literal: true

module Security
  module AnalyzersStatus
    class IngestionSubscriberWorker
      include Gitlab::EventStore::Subscriber

      data_consistency :sticky
      feature_category :security_asset_inventories
      idempotent!

      def handle_event(event)
        pipeline = ::Ci::Pipeline.find_by_id(event.data[:pipeline_id])
        return unless pipeline&.default_branch?
        return unless ::Feature.enabled?(:analyzers_status_from_security_scans, pipeline.project)

        ::Security::PipelineAnalyzersStatusUpdateWorker.perform_async(pipeline.id)
      end
    end
  end
end
