# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::SystemDefined::Plan, feature_category: :plan_provisioning do
  describe '.all' do
    it 'includes the JH team plan' do
      expect(described_class.all).to include(have_attributes(id: 10_000, name: 'team', title: 'Team'))
    end
  end

  describe '.tier_for' do
    it 'keeps the Team tier separate from Premium' do
      expect(described_class.tier_for('team')).to eq('team')
    end

    it 'uses the upstream tier for non-Team plans', :aggregate_failures do
      expect(described_class.tier_for('free')).to eq('free')
      expect(described_class.tier_for('premium_trial')).to eq('premium')
      expect(described_class.tier_for('opensource')).to eq('ultimate')
    end
  end

  describe '#paid_excluding_trials?' do
    it 'treats Team as a paid plan without a trial', :aggregate_failures do
      plan = described_class.find_by!(name: 'team')

      expect(plan.paid?).to be(true)
      expect(plan.paid_excluding_trials?).to be(true)
      expect(plan.paid_excluding_trials?(exclude_oss: true)).to be(true)
    end
  end
end
