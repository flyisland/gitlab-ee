# frozen_string_literal: true

# This class provides current status of Shared Runners minutes usage for a namespace
# taking in consideration the monthly minutes allowance that Gitlab.com provides and
# any possible purchased minutes.

module Ci
  module Minutes
    class Usage
      include Gitlab::Utils::StrongMemoize

      attr_reader :namespace, :quota

      def initialize(namespace)
        @namespace = namespace
        @quota = ::Ci::Minutes::Quota.new(namespace)
      end

      def quota_enabled?
        quota.enabled?
      end

      def minutes_used_up?
        quota_enabled? && total_minutes_used >= quota.total
      end

      def percent_total_minutes_remaining
        return 0 unless quota_enabled?

        100 * total_minutes_remaining.to_f / quota.total.to_f
      end

      def current_balance
        quota.total - total_minutes_used
      end

      def total_minutes_used
        if Feature.enabled?(:aggregate_ci_minutes_reads, namespace)
          ::Ci::Minutes::NamespaceMonthlyUsage.total_current_minutes_used(namespace.id)
        else
          current_usage.amount_used.to_i
        end
      end

      def reset_date
        current_usage&.date ||
          Ci::Minutes::NamespaceMonthlyUsage.previous_usage(namespace)&.date ||
          Date.current.beginning_of_month # Fallback to a dummy current month until a record is created
      end

      # === private to view ===
      def monthly_minutes_used_up?
        return false unless quota_enabled?

        monthly_minutes_used >= quota.monthly
      end

      def monthly_minutes_used
        total_minutes_used - purchased_minutes_used
      end

      def purchased_minutes_used_up?
        return false unless quota_enabled?

        quota.any_purchased? && purchased_minutes_used >= quota.purchased
      end

      def purchased_minutes_used
        return 0 if !quota.any_purchased? || monthly_minutes_available?

        total_minutes_used - quota.monthly
      end

      private

      def current_usage
        @current_usage ||= if Feature.enabled?(:aggregate_ci_minutes_reads, namespace)
                             ::Ci::Minutes::NamespaceMonthlyUsage.all_current_usages(namespace.id).first
                           else
                             ::Ci::Minutes::NamespaceMonthlyUsage.find_or_create_current(namespace_id: namespace.id)
                           end
      end

      def monthly_minutes_available?
        total_minutes_used <= quota.monthly
      end

      def total_minutes_remaining
        [current_balance, 0].max
      end
    end
  end
end
