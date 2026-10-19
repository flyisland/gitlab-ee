# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    # Tier gate for the Orbit (Knowledge Graph) feature.
    #
    # SaaS: entitled when the user holds Reporter+ on any path whose root
    # namespace is entitled (see `entitled?`). Roots are resolved via
    # `traversal_ids.first` because `authorized_groups.top_level` is empty
    # for subgroup-only members (it excludes ancestors of direct memberships).
    #
    # Self-managed: delegates to the instance license.
    module OrbitLicense
      CACHE_KEY = 'orbit_feature_licensed'
      POSITIVE_CACHE_PERIOD = 30.minutes
      NEGATIVE_CACHE_PERIOD = 2.minutes

      def self.available_for?(user)
        return false unless user

        return ::License.feature_available?(:orbit) unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

        key = ['users', user.id, CACHE_KEY]

        cached = Rails.cache.read(key)
        return cached unless cached.nil?

        orbit_available = entitled_via_reporter_plus_root?(user)

        Rails.cache.write(
          key,
          orbit_available,
          expires_in: orbit_available ? POSITIVE_CACHE_PERIOD : NEGATIVE_CACHE_PERIOD
        )

        orbit_available
      end

      # Checks entitlement on the root namespace of each authorized path so
      # subgroup-only members inherit the license of their root.
      def self.entitled_via_reporter_plus_root?(user)
        root_namespace_ids = ::Analytics::KnowledgeGraph::AuthorizationContext
          .new(user)
          .reporter_plus_root_namespace_ids

        return false if root_namespace_ids.empty?

        roots = ::Group.id_in(root_namespace_ids).include_gitlab_subscription_with_hosted_plan.to_a
        gated_roots, plan_tier_roots = roots.partition { |root| promo_gate_enabled?(root) }

        plan_tier_roots.any? { |root| root.licensed_feature_available?(:orbit) } ||
          promo_entitled_root_ids(gated_roots.map(&:id)).any?
      end

      def self.entitled?(resource)
        root = resource.root_ancestor
        return resource.licensed_feature_available?(:orbit) unless promo_gate_enabled?(root)

        promo_entitled_root_ids([root.id]).any?
      end

      def self.reject_gated_root_ids_without_access(root_ids)
        gated_ids = root_ids.select { |id| promo_gate_enabled?(::Group.actor_from_id(id)) }
        return root_ids if gated_ids.empty?

        root_ids - (gated_ids - promo_entitled_root_ids(gated_ids))
      end

      def self.namespace_eligible?(root)
        root.licensed_feature_available?(:orbit) || promo_add_on_active?(root)
      end

      def self.promo_gate_enabled?(root)
        ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions) &&
          ::Feature.enabled?(:orbit_promo_access_gate, root)
      end

      def self.promo_add_on_active?(root)
        promo_gate_enabled?(root) && orbit_promo_purchased?(root)
      end

      def self.orbit_promo_purchased?(root)
        ::GitlabSubscriptions::AddOnPurchase.for_orbit_promo.active.by_namespace(root).exists?
      end
      private_class_method :orbit_promo_purchased?

      # The ended-trials cron only checks roots with Orbit on, so only their trial rows are current.
      def self.promo_entitled_root_ids(root_ids)
        return [] if root_ids.empty?

        add_on_root_ids = ::GitlabSubscriptions::AddOnPurchase.for_orbit_promo.active
          .by_namespace(root_ids).uniq_namespace_ids
        enabled_namespaces = ::Analytics::KnowledgeGraph::EnabledNamespace.for_root_namespace_id(root_ids)
        trial_root_ids = ::Analytics::Orbit::NamespaceEnrollment.trials_not_ended_for(enabled_namespaces)
          .pluck_primary_key

        add_on_root_ids | trial_root_ids
      end
      private_class_method :promo_entitled_root_ids
    end
  end
end
