# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    class ExpireTraversalIdCacheWorker
      include Gitlab::EventStore::Subscriber

      data_consistency :delayed
      feature_category :knowledge_graph
      urgency :low
      deduplicate :until_executed
      defer_on_database_health_signal :gitlab_main
      idempotent!

      def handle_event(event)
        user_ids = extract_user_ids(event)
        return if user_ids.blank?

        AuthorizationContext.expire_cache_for_users(user_ids)
      end

      private

      def extract_user_ids(event)
        event.data[:user_ids] || event.data[:invited_user_ids] || Array.wrap(event.data[:user_id]).compact
      end
    end
  end
end
