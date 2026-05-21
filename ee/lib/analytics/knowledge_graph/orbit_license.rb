# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    # Tier gate for the Orbit (Knowledge Graph) feature.
    #
    # SaaS resolves per user. Orbit is available if any of the user's
    # authorized top-level groups carries the :orbit licensed feature; the
    # boolean is cached for an hour to avoid repeated group iteration on hot
    # paths (MCP, Data API).
    #
    # Self-managed delegates to the instance license. Group iteration would be
    # both redundant (every group inherits the instance tier) and incorrect for
    # users with no top-level group memberships, who would otherwise be denied
    # on a fully licensed instance.
    module OrbitLicense
      CACHE_KEY = 'orbit_feature_licensed'
      CACHE_PERIOD = 1.hour

      def self.feature_flag_enabled?(user)
        Feature.enabled?(:knowledge_graph, user)
      end

      def self.available_for?(user)
        return false unless user

        return ::License.feature_available?(:orbit) unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

        Rails.cache.fetch(
          ['users', user.id, CACHE_KEY],
          expires_in: CACHE_PERIOD
        ) do
          user.authorized_groups.top_level.any? do |group|
            group.licensed_feature_available?(:orbit)
          end
        end
      end
    end
  end
end
