# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    class GoverningNamespaceFinder
      def initialize(user)
        @user = user
      end

      def candidates
        if ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
          saas_candidates
        else
          user.authorized_groups.top_level
        end
      end

      def eligible?(namespace_id)
        return false unless namespace_id

        candidates.exists?(id: namespace_id) # rubocop:disable CodeReuse/ActiveRecord -- finder-built relation
      end

      def single_candidate_fallback
        namespaces = candidates.limit(2).to_a
        namespaces.first if namespaces.size == 1
      end

      private

      attr_reader :user

      def saas_candidates
        gitlab_credits_namespace_ids = ::GitlabSubscriptions::AddOnPurchase
          .for_gitlab_credits
          .active
          .for_user(user)
          .select_distinct_namespace_id

        paid_premium_or_ultimate_namespace_ids = ::GitlabSubscription
          .with_hosted_plan([::Plan::PREMIUM, ::Plan::ULTIMATE])
          .namespace_id_in(user.gitlab_com_root_group_ids)
          .select(:namespace_id)

        ::Namespace.from_union([
          ::Namespace.id_in(gitlab_credits_namespace_ids),
          ::Namespace.id_in(paid_premium_or_ultimate_namespace_ids)
        ])
      end
    end
  end
end
