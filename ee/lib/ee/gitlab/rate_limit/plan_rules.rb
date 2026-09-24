# frozen_string_literal: true

module EE
  module Gitlab
    module RateLimit
      module PlanRules
        extend ActiveSupport::Concern

        UNAUTHENTICATED_RULES = [
          ::Labkit::RateLimit::Rule.new(
            name: 'unauthenticated_traffic_per_ip', action: :limit,
            match: { requester_id: nil, runner_id: nil,
                     unauthenticated_limits_active: true, unauthenticated_enforced: true },
            characteristics: %i[ip], limit: 60, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'unauthenticated_traffic_per_ip_log', action: :log,
            match: { requester_id: nil, runner_id: nil,
                     unauthenticated_limits_active: true, unauthenticated_enforced: false },
            characteristics: %i[ip], limit: 60, period: 1.hour
          )
        ].freeze

        FLAGS = [
          :rate_limiter_plan_limits_free_info,
          :rate_limiter_plan_limits_free_enforce,
          :rate_limiter_plan_limits_premium_info,
          :rate_limiter_plan_limits_premium_enforce,
          :rate_limiter_plan_limits_ultimate_info,
          :rate_limiter_plan_limits_ultimate_enforce,
          :rate_limiter_unauthenticated_limits_info,
          :rate_limiter_unauthenticated_limits_enforce
        ].freeze

        class_methods do
          extend ::Gitlab::Utils::Override

          override :flags
          def flags
            FLAGS
          end

          # SaaS first, so no flag is read off GitLab.com where no plan rule can match
          override :active?
          def active?
            return false unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

            actor = ::Feature.current_request

            ::Feature.enabled?(:rate_limiter_plan_limits_free_info, actor, type: :gitlab_com_derisk) ||
              ::Feature.enabled?(:rate_limiter_plan_limits_free_enforce, actor, type: :gitlab_com_derisk) ||
              ::Feature.enabled?(:rate_limiter_plan_limits_premium_info, actor, type: :gitlab_com_derisk) ||
              ::Feature.enabled?(:rate_limiter_plan_limits_premium_enforce, actor, type: :gitlab_com_derisk) ||
              ::Feature.enabled?(:rate_limiter_plan_limits_ultimate_info, actor, type: :gitlab_com_derisk) ||
              ::Feature.enabled?(:rate_limiter_plan_limits_ultimate_enforce, actor, type: :gitlab_com_derisk) ||
              ::Feature.enabled?(:rate_limiter_unauthenticated_limits_info, actor, type: :gitlab_com_derisk) ||
              ::Feature.enabled?(:rate_limiter_unauthenticated_limits_enforce, actor, type: :gitlab_com_derisk)
          end

          override :for_limiter
          def for_limiter(limiter_name)
            return [] unless limiter_name == ::Gitlab::RackAttack::LabkitRateLimit::ThrottleRegistry::GENERAL
            return [] unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

            UNAUTHENTICATED_RULES
          end
        end
      end
    end
  end
end
