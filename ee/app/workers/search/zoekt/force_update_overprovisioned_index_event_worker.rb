# frozen_string_literal: true

module Search
  module Zoekt
    class ForceUpdateOverprovisionedIndexEventWorker
      include Gitlab::EventStore::Subscriber
      include Search::Zoekt::EventWorker
      prepend ::Geo::SkipSecondary

      idempotent!
      defer_on_database_health_signal :gitlab_main, [:zoekt_indices], 10.minutes

      BATCH_SIZE = 1000

      def handle_event(_event)
        # when FF zoekt_batch_update_index_storage_bytes is enabled it uses optimized bulk index updates
        # The FF name suggests it for storage_bytes, but it is basically bulk update vs individual update.
        if Feature.enabled?(:zoekt_batch_update_index_storage_bytes, Feature.current_request)
          updates = Index.overprovisioned.ready.with_latest_used_storage_bytes_updated_at.limit(BATCH_SIZE).map do |idx|
            idx.compute_storage_bytes_and_watermark_level(skip_used_storage_bytes: true)
          end
          Index.bulk_update_storage_bytes_and_watermark_level!(updates)
        else
          Index.overprovisioned.ready.with_latest_used_storage_bytes_updated_at.limit(BATCH_SIZE).each do |index|
            index.update_storage_bytes_and_watermark_level!(skip_used_storage_bytes: true)
          end
        end

        reemit_event
      end

      private

      def reemit_event
        return unless Index.overprovisioned.ready.with_latest_used_storage_bytes_updated_at.exists?

        Gitlab::EventStore.publish(Search::Zoekt::ForceUpdateOverprovisionedIndexEvent.new(data: {}))
      end
    end
  end
end
