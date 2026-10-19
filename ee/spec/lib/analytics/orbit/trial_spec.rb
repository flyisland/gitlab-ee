# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::Orbit::Trial, feature_category: :knowledge_graph do
  using RSpec::Parameterized::TableSyntax

  describe '.available_for?' do
    let_it_be(:group) { create(:group) }

    subject { described_class.available_for?(group) }

    where(:saas, :flag, :expected) do
      true  | true  | true
      true  | false | false
      false | true  | false
    end

    with_them do
      before do
        stub_saas_features(gitlab_com_subscriptions: saas)
        stub_feature_flags(orbit_trial: flag)
      end

      it { is_expected.to eq(expected) }
    end
  end

  describe '.status_for' do
    let_it_be(:group) { create(:group) }
    let(:response) { Gitlab::SubscriptionPortal::ProductTrialResponse.new(state: :trial_eligible) }

    it 'reads the orbit trial of the group from CDot with a timeout' do
      expect(Gitlab::SubscriptionPortal::Client).to receive(:product_trial)
        .with(trial_type: :orbit, namespace_id: group.id, timeout: 2.0)
        .and_return(response)

      expect(described_class.status_for(group)).to eq(response)
    end

    it 'uses the client default timeouts when the caller gives timeout: nil' do
      expect(Gitlab::SubscriptionPortal::Client).to receive(:product_trial)
        .with(trial_type: :orbit, namespace_id: group.id, timeout: nil)
        .and_return(response)

      expect(described_class.status_for(group, timeout: nil)).to eq(response)
    end
  end
end
