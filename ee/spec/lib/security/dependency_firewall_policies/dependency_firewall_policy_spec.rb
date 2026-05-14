# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyFirewallPolicies::DependencyFirewallPolicy, feature_category: :security_policy_management do
  let(:policy_content) do
    {
      name: 'Test Dependency Firewall Policy',
      enabled: true,
      enforcement_type: 'enforced',
      rules: [
        {
          type: 'license',
          denied: [{ name: 'NIST Software License' }, { name: 'NTP License' }],
          exceptions: [{ purl: 'pkg:npm/myinternallib' }]
        },
        {
          type: 'license',
          allowed: [{ name: 'MIT License' }, { name: 'Nokia Open Source License' }],
          exceptions: [{ purl: 'pkg:npm/myexternallib' }]
        }
      ],
      bypass_settings: { users: [{ id: 1222 }], access_tokens: [{ id: 222 }] }
    }
  end

  let(:policy_record) do
    create(:security_policy, :dependency_firewall_policy,
      name: 'Test Dependency Firewall Policy',
      description: 'Test Description',
      enabled: true,
      content: policy_content)
  end

  let(:dependency_firewall_policy) { described_class.new(policy_record) }

  describe '#rules' do
    subject(:rules) { dependency_firewall_policy.rules }

    it 'returns a Rules instance' do
      expect(rules).to be_a(Security::DependencyFirewallPolicies::Rules)
    end

    it 'contains the correct rules' do
      expect(rules.rules).to eq(policy_content[:rules])
      expect(rules.count).to eq(2)
    end
  end

  describe 'inherited methods from BaseSecurityPolicy' do
    it 'delegates name to policy_record' do
      expect(dependency_firewall_policy.name).to eq('Test Dependency Firewall Policy')
    end

    it 'delegates description to policy_record' do
      expect(dependency_firewall_policy.description).to eq('Test Description')
    end

    it 'delegates enabled to policy_record' do
      expect(dependency_firewall_policy.enabled).to be true
    end
  end
end
