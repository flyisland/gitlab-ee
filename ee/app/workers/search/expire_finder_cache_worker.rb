# frozen_string_literal: true

module Search
  class ExpireFinderCacheWorker # rubocop:disable Sidekiq/EnforceDatabaseHealthSignalDeferral -- Worker only writes to Redis
    include Gitlab::EventStore::Subscriber
    include ::Geo::SkipSecondary

    feature_category :global_search
    urgency :low
    deduplicate :until_executed
    idempotent!

    def handle_event(event)
      user_ids = extract_user_ids(event)
      return if user_ids.blank?

      ::Search::GroupsFinder.expire_cache_for_users(user_ids)
      ::Search::ProjectsFinder.expire_cache_for_users(user_ids)
    end

    private

    def extract_user_ids(event)
      event.data[:user_ids] ||
        event.data[:invited_user_ids] ||
        Array.wrap(event.data[:user_id] || event.data[:member_user_id]).compact
    end
  end
end
