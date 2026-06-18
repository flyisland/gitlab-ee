# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    # Tier gate for the Orbit (Knowledge Graph) feature.
    #
    # SaaS resolves per user. Orbit is available if any of the user's
    # authorized top-level groups carries the :orbit licensed feature; the
    # boolean is cached to avoid repeated group iteration on hot paths
    # (MCP, Data API).
    #
    # The cached result uses differentiated TTLs: longer when authorized, shorter
    # when denied, so a user who upgrades regains access within minutes.
    #
    # Self-managed delegates to the instance license. Group iteration would be
    # both redundant (every group inherits the instance tier) and incorrect for
    # users with no top-level group memberships, who would otherwise be denied
    # on a fully licensed instance.
    module OrbitLicense
      CACHE_KEY = 'orbit_feature_licensed'
      POSITIVE_CACHE_PERIOD = 30.minutes
      NEGATIVE_CACHE_PERIOD = 2.minutes

      def self.feature_flag_enabled?(user)
        Feature.enabled?(:knowledge_graph, user)
      end

      def self.available_for?(user)
        return false unless user

        return ::License.feature_available?(:orbit) unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

        key = ['users', user.id, CACHE_KEY]

        cached = Rails.cache.read(key)
        return cached unless cached.nil?

        orbit_available = user.authorized_groups.top_level.any? do |group|
          group.licensed_feature_available?(:orbit) && namespace_enrollable_or_enrolled?(group)
        end

        Rails.cache.write(
          key,
          orbit_available,
          expires_in: orbit_available ? POSITIVE_CACHE_PERIOD : NEGATIVE_CACHE_PERIOD
        )

        orbit_available
      end

      def self.namespace_enrollable_or_enrolled?(group)
        ::Feature.enabled?(:orbit_enroll_namespace, group) ||
          EnabledNamespace.for_root_namespace_id(group.id).exists?
      end
    end
  end
end
