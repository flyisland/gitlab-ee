# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Group do
  using RSpec::Parameterized::TableSyntax

  describe 'validations' do
    it_behaves_like "content validation", :group, :name
  end

  describe '#actual_size_limit', :saas do
    let_it_be(:group) { create(:group) }
    let_it_be(:ultimate_limits) { create(:plan_limits, plan: create(:ultimate_plan), repository_size: 100) }
    let_it_be(:ultimate_group) { create(:group_with_plan, plan: :ultimate_plan) }

    before do
      allow(::Gitlab).to receive(:jh?).and_return(true)
    end

    it 'returns the actual size limit' do
      expect(ultimate_group.actual_size_limit).to eq(100)
      expect(group.actual_size_limit).to eq(::Gitlab::CurrentSettings.repository_size_limit.to_i)
    end
  end

  describe '#block_seat_overages?', :saas do
    let_it_be(:free_group, freeze: false) { create(:group) }
    let_it_be(:premium_group, freeze: false) { create(:group_with_plan, plan: :premium_plan) }
    let_it_be(:ultimate_group, freeze: false) { create(:group_with_plan, plan: :ultimate_plan) }
    let_it_be(:team_group, freeze: false) { create(:group_with_plan, plan: :team_plan) }

    where(
      :plan, :jh_only_block_seat_for_team_plan?, :gitlab_com_subscriptions?, :expected_result) do
      # When :jh_only_block_seat_for_team_plan is enabled
      :team     | true | true  | true

      :free     | true | true  | false
      :premium  | true | true  | false
      :ultimate | true | true  | false
      :team     | true | false | false

      # When :jh_only_block_seat_for_team_plan is disabled
      :free     | false | true | true
      :team     | false | true | true
      :premium  | false | true | true
      :ultimate | false | true | true
    end

    with_them do
      let(:group) { public_send(:"#{plan}_group") }

      before do
        stub_feature_flags(jh_only_block_seat_for_team_plan: jh_only_block_seat_for_team_plan?)
        stub_saas_features(gitlab_com_subscriptions: gitlab_com_subscriptions?)
        group.namespace_settings.update!(seat_control: :block_overages, new_user_signups_cap: nil)
      end

      it 'returns the expected result' do
        expect(group.block_seat_overages?).to eq(expected_result)
      end
    end
  end
end
