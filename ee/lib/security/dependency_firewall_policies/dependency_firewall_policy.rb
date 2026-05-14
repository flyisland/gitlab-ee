# frozen_string_literal: true

module Security
  module DependencyFirewallPolicies
    class DependencyFirewallPolicy < Security::BaseSecurityPolicy
      def rules
        Security::DependencyFirewallPolicies::Rules.new(policy_content[:rules] || [])
      end

      private

      def policy_content
        policy_record.policy_content
      end
    end
  end
end
