# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    class AuthorizationContext
      include Gitlab::Utils::StrongMemoize

      MAX_TRAVERSAL_IDS = 500
      CACHE_TTL = 5.minutes

      def self.expire_cache_for_users(user_ids)
        Rails.cache.delete_multi(user_ids.map { |id| cache_key_for(id) })
      end

      def self.cache_key_for(user_id)
        "analytics:knowledge_graph:traversal_ids:#{user_id}"
      end

      def initialize(user)
        @user = user
      end

      def admin_user?
        return false unless user

        user.can_read_all_resources?
      end

      def anonymous_user?
        user.nil?
      end

      def reporter_plus_traversal_ids
        return { group_traversal_ids: [] } unless user

        { group_traversal_ids: reporter_plus_group_traversal_ids }
      end

      attr_reader :user

      private

      def cache_key
        self.class.cache_key_for(user.id)
      end

      def reporter_plus_group_traversal_ids
        Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
          start = ::Gitlab::Metrics::System.monotonic_time

          traversal_ids_with_org = authorized_group_traversal_ids
          if traversal_ids_with_org.empty?
            observe_auth_context_duration(start)
            next []
          end

          trie = ::Namespaces::Traversal::TrieNode.build(traversal_ids_with_org)
          compacted_ids = trie.to_a
          original_count = compacted_ids.size

          metrics.observe_traversal_ids_count(original_count)

          if original_count > MAX_TRAVERSAL_IDS
            metrics.increment_threshold_exceeded
            compacted_ids = compact_traversal_ids(compacted_ids, MAX_TRAVERSAL_IDS)

            log_threshold_exceeded(original_count, compacted_ids.size)
          end

          observe_compaction_ratio(traversal_ids_with_org.size, compacted_ids.size)

          observe_auth_context_duration(start)
          format_traversal_ids(compacted_ids)
        end
      end
      strong_memoize_attr :reporter_plus_group_traversal_ids

      def compact_traversal_ids(traversal_ids, limit)
        ::Gitlab::Utils::TraversalIdCompactor.compact(traversal_ids, limit)
      rescue ::Gitlab::Utils::TraversalIdCompactor::CompactionLimitCannotBeAchievedError
        metrics.increment_compaction_fallback
        log_compaction_fallback(traversal_ids.size, limit)

        traversal_ids.first(limit)
      end

      def log_threshold_exceeded(original_count, compacted_count)
        logger.warn(
          message: 'Traversal ID count exceeds threshold',
          Labkit::Fields::GL_USER_ID => user.id,
          traversal_ids_count: original_count,
          compacted_count: compacted_count,
          threshold: MAX_TRAVERSAL_IDS
        )
      end

      def log_compaction_fallback(traversal_ids_count, limit)
        logger.error(
          message: 'Traversal ID compaction limit cannot be achieved, falling back to truncation',
          Labkit::Fields::GL_USER_ID => user.id,
          traversal_ids_count: traversal_ids_count,
          limit: limit,
          dropped_count: traversal_ids_count - limit
        )
      end

      def observe_compaction_ratio(original_count, compacted_count)
        return if original_count == 0

        ratio = compacted_count.to_f / original_count
        metrics.observe_compaction_ratio(ratio)
      end

      def observe_auth_context_duration(start)
        duration = ::Gitlab::Metrics::System.monotonic_time - start
        ::Gitlab::Metrics::KnowledgeGraph::Request.observe_auth_context_duration(duration)
      end

      def logger
        @logger ||= ::Gitlab::KnowledgeGraph::Logger.build
      end

      def metrics
        ::Gitlab::Metrics::KnowledgeGraph::TraversalIds
      end

      def authorized_group_traversal_ids
        ::Gitlab::SafeRequestStore.fetch("knowledge_graph:user:#{user.id}:reporter_plus_traversal_ids") do
          ::Search::GroupsFinder.new(
            user: user,
            params: { min_access_level: Gitlab::Access::REPORTER }
          ).execute
            .pluck(:organization_id, :traversal_ids) # rubocop:disable CodeReuse/ActiveRecord -- avoids loading full AR objects
            .map { |org_id, t_ids| [org_id] + t_ids }
        end
      end

      # Uses slash separator for ClickHouse startsWith prefix matching.
      # Search uses dash separator (see authorization_utils.rb).
      def format_traversal_ids(traversal_ids)
        traversal_ids.map { |id_array| "#{id_array.join('/')}/" }
      end
    end
  end
end
