# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Plan, feature_category: :subscription_management do
  using RSpec::Parameterized::TableSyntax

  describe '.tier_for' do
    where(:plan_name, :expected_tier) do
      'default'                      | 'free'
      'free'                         | 'free'
      'early_adopter'                | 'free'
      'team'                         | 'team'
      'bronze'                       | 'premium'
      'silver'                       | 'premium'
      'premium'                      | 'premium'
      'premium_trial'                | 'premium'
      'gold'                         | 'ultimate'
      'opensource'                   | 'ultimate'
      'ultimate'                     | 'ultimate'
      'ultimate_trial'               | 'ultimate'
      'ultimate_trial_paid_customer' | 'ultimate'
      'nonexistent' | 'free'
    end

    with_them do
      it 'resolves the subscription tier' do
        expect(described_class.tier_for(plan_name)).to eq(expected_tier)
      end
    end

    it 'maps every system-defined plan to a tier', :aggregate_failures do
      plans = GitlabSubscriptions::SystemDefined::Plan.all.map(&:name)

      expect(plans).to contain_exactly(
        'default', 'free', 'early_adopter', 'team', 'bronze', 'silver', 'premium', 'premium_trial',
        'opensource', 'gold', 'ultimate', 'ultimate_trial', 'ultimate_trial_paid_customer'
      )
      expect(plans.map { |name| described_class.tier_for(name) }).to all(be_in(described_class::TIERS))
    end
  end

  describe '.plan_name_uids' do
    it 'returns hash with "team: 10000"' do
      expect(described_class.plan_name_uids).to include('team' => 10000)
    end

    it 'does not include "10000" in PLAN_NAME_UID_LIST.values' do
      expect(described_class::PLAN_NAME_UID_LIST.values).not_to include(10000)
    end
  end
end
