# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SubscriptionsHelper, feature_category: :subscription_management do
  using RSpec::Parameterized::TableSyntax

  let(:free_plan) do
    { "name" => "Free Plan", "free" => true, "code" => "free" }
  end

  let(:team_plan) do
    {
      "id" => "team_id",
      "name" => "Team Plan",
      "free" => false,
      "code" => "team",
      "price_per_year" => 48.0
    }
  end

  let(:bronze_plan) do
    {
      "id" => "bronze_id",
      "name" => "Bronze Plan",
      "free" => false,
      "code" => "bronze",
      "price_per_year" => 48.0
    }
  end

  let(:raw_plan_data) do
    [free_plan, bronze_plan, team_plan]
  end

  before do
    allow(helper).to receive(:params).and_return(plan_id: 'bronze_id', namespace_id: nil)
    allow_next_instance_of(GitlabSubscriptions::FetchSubscriptionPlansService) do |instance|
      allow(instance).to receive(:execute).and_return(raw_plan_data)
    end
  end

  describe '#subscription_data' do
    let(:user) { create(:user, :with_namespace, onboarding_status_setup_for_company: false, name: 'First Last') }
    let(:group) { create(:group, name: 'My Namespace') }
    let(:available_plans) { helper.send(:subscription_available_plans) } # rubocop:disable GitlabSecurity/PublicSend -- Intentional meta programming to direct to correct type

    before do
      allow(helper).to receive(:current_user).and_return(user)
      group.add_owner(user)
    end

    it 'returns team plan at the first position' do
      expect(available_plans).to eq(
        [{ id: "team_id", code: "team", price_per_year: 48.0, name: "Team Plan" },
          { id: "bronze_id", code: "bronze", price_per_year: 48.0, name: "Bronze Plan" }])
    end
  end
end
