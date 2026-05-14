# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Security::DependencyFirewallPolicies::Rules, feature_category: :security_policy_management do
  let(:rules_data) do
    [
      { type: 'block', package_name: 'lodash' },
      { type: 'allow', package_name: 'react' }
    ]
  end

  let(:rules) { described_class.new(rules_data) }

  describe '#initialize' do
    it 'stores the rules' do
      expect(rules.rules).to eq(rules_data)
    end

    context 'when rules is nil' do
      let(:rules) { described_class.new(nil) }

      it 'initializes with empty array' do
        expect(rules.rules).to eq([])
      end
    end
  end

  describe 'enumerable methods' do
    it 'responds to each' do
      expect(rules).to respond_to(:each)
    end

    it 'responds to []' do
      expect(rules).to respond_to(:[])
    end

    it 'responds to map' do
      expect(rules).to respond_to(:map)
    end

    it 'iterates over rules' do
      expect(rules.pluck(:type)).to eq(%w[block allow])
    end

    it 'allows array access' do
      expect(rules[0]).to eq({ type: 'block', package_name: 'lodash' })
      expect(rules[1]).to eq({ type: 'allow', package_name: 'react' })
    end
  end
end
