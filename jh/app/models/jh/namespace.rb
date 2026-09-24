# frozen_string_literal: true

module JH
  module Namespace
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    override :actual_size_limit
    def actual_size_limit
      return super unless ::Gitlab.jh? && ::Gitlab.com?
      return super if actual_limits.repository_size.nil?

      actual_limits.repository_size
    end

    # rubocop:disable Gitlab/StrongMemoizeAttr -- Skip StrongMemoizeAttr special cases
    override :licensed_feature_available?
    def licensed_feature_available?(feature)
      available_features = strong_memoize(:jh_licensed_feature_available) do
        Hash.new do |h, f|
          h[f] = load_feature_available(f)
        end
      end

      available_features[feature]
    end
    # rubocop:enable Gitlab/StrongMemoizeAttr

    override :clear_feature_available_cache
    def clear_feature_available_cache
      clear_memoization(:jh_licensed_feature_available)

      super
    end

    def team_plan?
      actual_plan_name == ::Plan::TEAM
    end

    # `Namespace#actual_plan` will generate a gitlab subscription by default.
    # The current method does not generate, it simply reads data.
    def actual_plan_without_generate_subscription
      ::Gitlab::SafeRequestStore.fetch(actual_plan_without_generate_subscription_store_key) do
        next ::Plan.default unless ::Gitlab.com?

        if parent_id
          root_ancestor.actual_plan_without_generate_subscription
        else
          hosted_plan_for(gitlab_subscription) || ::Plan.free
        end
      end
    end

    private

    def actual_plan_without_generate_subscription_store_key
      "namespaces:#{id}:actual_plan_without_generate_subscription"
    end
  end
end
