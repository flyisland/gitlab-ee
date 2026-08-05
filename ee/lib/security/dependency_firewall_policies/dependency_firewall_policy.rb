# frozen_string_literal: true

module Security
  module DependencyFirewallPolicies
    class DependencyFirewallPolicy < Security::BaseSecurityPolicy
      include Gitlab::Utils::StrongMemoize

      def enforcement_type
        policy_content[:enforcement_type]
      end

      def rules
        policy_rules = policy_record
                         .undeleted_dependency_firewall_policy_rules
                         .map(&:typed_content)
                         .map(&:deep_symbolize_keys)

        ::Security::DependencyFirewallPolicies::Rules.new(policy_rules || [])
      end
      strong_memoize_attr :rules

      def bypass_settings
        Security::DependencyFirewallPolicies::BypassSettings.new(policy_content[:bypass_settings])
      end
      strong_memoize_attr :bypass_settings

      def policy_content
        policy_record.policy_content
      end
    end
  end
end
