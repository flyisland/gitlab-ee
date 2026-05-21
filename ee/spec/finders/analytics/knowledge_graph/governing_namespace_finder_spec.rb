# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::GoverningNamespaceFinder, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user, :with_namespace) }

  subject(:finder) { described_class.new(user) }

  describe '#candidates' do
    context 'when SaaS', :saas do
      before do
        stub_saas_features(gitlab_com_subscriptions: true)
      end

      context 'when user belongs to namespaces with various add-on and plan configurations' do
        let_it_be(:gitlab_credits_add_on) { create(:gitlab_subscription_add_on, :gitlab_credits) }
        let_it_be(:duo_enterprise_add_on) { create(:gitlab_subscription_add_on, :duo_enterprise) }

        # Eligible via active gitlab_credits purchase
        let_it_be(:gitlab_credits_namespace) { create(:group, name: 'gitlab_credits_namespace') }
        # Eligible via paid plan
        let_it_be(:premium_namespace) { create(:group, name: 'premium_namespace') }
        let_it_be(:ultimate_namespace) { create(:group, name: 'ultimate_namespace') }
        # Eligible via both branches (asserts dedup)
        let_it_be(:premium_with_credits_namespace) { create(:group, name: 'premium_with_credits_namespace') }
        # Not eligible
        let_it_be(:gitlab_credits_expired_namespace) { create(:group, name: 'gitlab_credits_expired_namespace') }
        let_it_be(:duo_only_namespace) { create(:group, name: 'duo_only_namespace') }
        let_it_be(:premium_trial_namespace) { create(:group, name: 'premium_trial_namespace') }
        let_it_be(:ultimate_trial_namespace) { create(:group, name: 'ultimate_trial_namespace') }
        let_it_be(:free_namespace) { create(:group, name: 'free_namespace') }

        let!(:gitlab_credits_purchase) do
          create(:gitlab_subscription_add_on_purchase,
            namespace: gitlab_credits_namespace, add_on: gitlab_credits_add_on)
        end

        let!(:expired_gitlab_credits_purchase) do
          create(:gitlab_subscription_add_on_purchase,
            namespace: gitlab_credits_expired_namespace, add_on: gitlab_credits_add_on, expires_on: 1.day.ago)
        end

        let!(:duo_only_purchase) do
          create(:gitlab_subscription_add_on_purchase, namespace: duo_only_namespace, add_on: duo_enterprise_add_on)
        end

        let!(:premium_with_credits_purchase) do
          create(:gitlab_subscription_add_on_purchase,
            namespace: premium_with_credits_namespace, add_on: gitlab_credits_add_on)
        end

        let_it_be(:premium_subscription) do
          create(:gitlab_subscription, :premium, namespace: premium_namespace)
        end

        let_it_be(:ultimate_subscription) do
          create(:gitlab_subscription, :ultimate, namespace: ultimate_namespace)
        end

        let_it_be(:premium_with_credits_subscription) do
          create(:gitlab_subscription, :premium, namespace: premium_with_credits_namespace)
        end

        let_it_be(:premium_trial_subscription) do
          create(:gitlab_subscription, :premium, :active_trial, namespace: premium_trial_namespace)
        end

        let_it_be(:ultimate_trial_subscription) do
          create(:gitlab_subscription, :ultimate, :active_trial, namespace: ultimate_trial_namespace)
        end

        before do
          [gitlab_credits_namespace, gitlab_credits_expired_namespace, duo_only_namespace,
            premium_namespace, ultimate_namespace, premium_with_credits_namespace,
            premium_trial_namespace, ultimate_trial_namespace, free_namespace].each do |namespace|
            namespace.add_developer(user)
          end
        end

        it 'returns the union of credits-having and paid premium/ultimate namespaces, deduplicated' do
          expect(finder.candidates).to match_array([
            gitlab_credits_namespace,
            premium_namespace,
            ultimate_namespace,
            premium_with_credits_namespace
          ])
        end
      end

      it 'is empty when user has no eligible add-on purchases or paid plans' do
        expect(finder.candidates).to be_empty
      end
    end

    context 'when Self-Managed' do
      let_it_be(:top_level_group) { create(:group) }
      let_it_be(:subgroup) { create(:group, parent: top_level_group) }

      it 'returns top level authorized groups' do
        top_level_group.add_maintainer(user)
        subgroup.add_maintainer(user)

        result = finder.candidates

        expect(result).to include(top_level_group)
        expect(result).not_to include(subgroup)
      end
    end
  end

  describe '#eligible?' do
    let_it_be(:namespace) { create(:group, :private) }

    it 'returns false when namespace_id is nil' do
      expect(finder.eligible?(nil)).to be false
    end

    it 'returns true when the namespace is in candidates' do
      allow(finder).to receive(:candidates).and_return(Namespace.where(id: namespace.id))

      expect(finder.eligible?(namespace.id)).to be true
    end

    it 'returns false when the namespace is not in candidates' do
      allow(finder).to receive(:candidates).and_return(Namespace.none)

      expect(finder.eligible?(namespace.id)).to be false
    end
  end

  describe '#single_candidate_fallback' do
    let_it_be(:namespace) { create(:group, :private) }
    let_it_be(:other_namespace) { create(:group, :private) }

    it 'returns the namespace when exactly one candidate exists' do
      allow(finder).to receive(:candidates).and_return(Namespace.where(id: namespace.id))

      expect(finder.single_candidate_fallback).to eq(namespace)
    end

    it 'returns nil when multiple candidates exist' do
      allow(finder).to receive(:candidates)
        .and_return(Namespace.where(id: [namespace.id, other_namespace.id]))

      expect(finder.single_candidate_fallback).to be_nil
    end

    it 'returns nil when no candidates exist' do
      allow(finder).to receive(:candidates).and_return(Namespace.none)

      expect(finder.single_candidate_fallback).to be_nil
    end
  end
end
