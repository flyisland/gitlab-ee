# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::CachedPlanTier, :saas_gitlab_com_subscriptions, :request_store,
  :use_clean_rails_memory_store_caching, feature_category: :rate_limiting do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:user) { create(:user) }
  let_it_be(:team_group) { create(:group) }
  let_it_be(:team_subscription) { create(:gitlab_subscription, :team, namespace: team_group) }
  let_it_be(:membership) { create(:group_member, :developer, group: team_group, user: user) }

  describe '.for_root_namespace_id' do
    it 'preserves the Team tier' do
      expect(described_class.for_root_namespace_id(team_group.id)).to eq('team')
    end
  end

  describe '.for_user_id' do
    where(:other_plan, :expected_tier) do
      :free     | 'team'
      :team     | 'team'
      :premium  | 'premium'
      :ultimate | 'ultimate'
    end

    with_them do
      it 'ranks Team between Free and Premium' do
        group = create(:group)
        create(:gitlab_subscription, other_plan, namespace: group)
        create(:group_member, :developer, group: group, user: user)

        expect(described_class.for_user_id(user.id)).to eq(expected_tier)
      end
    end
  end
end
