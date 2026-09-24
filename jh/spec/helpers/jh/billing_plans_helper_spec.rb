# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BillingPlansHelper, :saas, feature_category: :subscription_management do
  include SubscriptionPortalHelpers

  describe '#number_to_plan_currency' do
    it 'returns the correct value and unit' do
      expect(helper.number_to_plan_currency(3.14)).to eq '¥3.14'
    end
  end

  describe '#billing_available_plans' do
    # rubocop:disable RSpec/VerifiedDoubles -- The code field is not implemented
    let(:plan) { double('Plan', deprecated?: false, code: 'free', hide_deprecated_card?: false) }
    let(:bronze_data) { double('Plan', deprecated?: false, code: 'bronze', hide_deprecated_card?: false) }
    let(:team_data) { double('Plan', deprecated?: false, code: 'team', hide_deprecated_card?: false) }
    # rubocop:enable RSpec/VerifiedDoubles
    let(:plans_data) { [plan, bronze_data, team_data] }

    describe 'when team plan' do
      subject(:available_plans) { helper.billing_available_plans(plans_data, plan) }

      it 'returns data without free plan and puts team plan to the beginning' do
        expect(available_plans.length).to eq(2)
        expect(available_plans.at(0)).to eq(team_data)
      end
    end
  end

  describe '#billing_plan_name' do
    it 'returns the correct name' do
      expect(helper.billing_plan_name(:free)).to eq 'Basic'
      expect(helper.billing_plan_name(:team)).to eq 'Team'
      expect(helper.billing_plan_name(:premium)).to eq 'Premium'
      expect(helper.billing_plan_name(:ultimate)).to eq 'Ultimate'
      expect(helper.billing_plan_name(:starter)).to eq 'Basic Extension'
      expect(helper.billing_plan_name(:premium_trial)).to eq 'Premium Trial'
      expect(helper.billing_plan_name(:ultimate_trial)).to eq 'Ultimate Trial'
    end
  end

  describe '#plans_features' do
    it 'returns the correct features list' do
      size = helper.plans_features.keys.size
      expect(size).to eq 4
      expect(helper.plans_features[:premium].size).to eq 6
    end
  end

  describe '#plan_purchase_url' do
    let_it_be(:group) { create(:group) }

    let(:plan) { double('Plan', id: 'plan-id') } # rubocop:disable RSpec/VerifiedDoubles -- those are not models or objects

    before do
      stub_feature_flags(migrate_purchase_flows_for_existing_customers: false)
      stub_signing_key
    end

    it 'builds Jihu subscriptions url' do
      user = create(:user)

      allow(helper).to receive_messages(current_user: user, params: { source: 'some_source' })

      expect(helper.plan_purchase_url(group, plan))
        .to include "/-/subscriptions/new?namespace_id=#{group.id}&plan_id=plan-id&source=some_source"
    end
  end
end
