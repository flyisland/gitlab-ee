# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::OrbitLicense, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }

  describe '.feature_flag_enabled?' do
    subject(:enabled) { described_class.feature_flag_enabled?(user) }

    context 'when the :knowledge_graph feature flag is on' do
      before do
        stub_feature_flags(knowledge_graph: true)
      end

      it { is_expected.to be(true) }
    end

    context 'when the :knowledge_graph feature flag is off' do
      before do
        stub_feature_flags(knowledge_graph: false)
      end

      it { is_expected.to be(false) }
    end
  end

  describe '.available_for?' do
    subject(:available) { described_class.available_for?(user) }

    context 'when user is nil' do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end

    context 'on self-managed' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
      end

      context 'when the instance license includes :orbit' do
        before do
          stub_licensed_features(orbit: true)
        end

        it { is_expected.to be(true) }
      end

      context 'when the instance license does not include :orbit' do
        before do
          stub_licensed_features(orbit: false)
        end

        it { is_expected.to be(false) }
      end
    end

    context 'on SaaS' do
      before do
        stub_saas_features(gitlab_com_subscriptions: true)
      end

      context 'when the user has no top-level groups' do
        it { is_expected.to be(false) }
      end

      context 'when the user belongs to a top-level group with :orbit' do
        let_it_be(:group) { create(:group).tap { |g| g.add_reporter(user) } }

        before do
          stub_licensed_features(orbit: true)
        end

        it { is_expected.to be(true) }
      end

      context 'when the user belongs to a top-level group without :orbit' do
        let_it_be(:group) { create(:group).tap { |g| g.add_reporter(user) } }

        before do
          stub_licensed_features(orbit: false)
        end

        it { is_expected.to be(false) }
      end

      context 'with caching', :use_clean_rails_memory_store_caching do
        let_it_be(:group) { create(:group).tap { |g| g.add_reporter(user) } }

        before do
          stub_licensed_features(orbit: true)
        end

        it 'evaluates the group iteration only once per user within the cache window' do
          expect(user).to receive(:authorized_groups).once.and_call_original

          2.times { described_class.available_for?(user) }
        end
      end
    end
  end
end
