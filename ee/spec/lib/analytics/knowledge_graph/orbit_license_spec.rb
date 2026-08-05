# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::OrbitLicense, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }

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

        context 'when :orbit_enroll_namespace is disabled for the group' do
          before do
            stub_feature_flags(orbit_enroll_namespace: false)
          end

          it { is_expected.to be(false) }

          context 'and the group is already enrolled' do
            before do
              create(:knowledge_graph_enabled_namespace, namespace: group)
            end

            it { is_expected.to be(true) }
          end
        end
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
        let(:cache_key) { ['users', user.id, described_class::CACHE_KEY] }

        context 'when the result is positive' do
          before do
            stub_licensed_features(orbit: true)
          end

          it 'evaluates the group iteration only once per user within the cache window' do
            expect(user).to receive(:authorized_groups).once.and_call_original

            2.times { described_class.available_for?(user) }
          end

          it 'caches the result with the positive TTL' do
            expect(Rails.cache).to receive(:write).with(
              cache_key, true, expires_in: described_class::POSITIVE_CACHE_PERIOD
            )

            described_class.available_for?(user)
          end
        end

        context 'when the result is negative' do
          before do
            stub_licensed_features(orbit: false)
          end

          it 'does not recompute a cached denied result within the cache window', :aggregate_failures do
            expect(user).to receive(:authorized_groups).once.and_call_original

            2.times { expect(described_class.available_for?(user)).to be(false) }
          end

          it 'caches the result with the negative TTL' do
            expect(Rails.cache).to receive(:write).with(
              cache_key, false, expires_in: described_class::NEGATIVE_CACHE_PERIOD
            )

            described_class.available_for?(user)
          end
        end
      end
    end
  end

  describe '.namespace_enrollable_or_enrolled?' do
    let_it_be(:group) { create(:group) }

    subject(:enrollable) { described_class.namespace_enrollable_or_enrolled?(group) }

    context 'when :orbit_enroll_namespace is enabled for the group' do
      it { is_expected.to be(true) }
    end

    context 'when :orbit_enroll_namespace is disabled' do
      before do
        stub_feature_flags(orbit_enroll_namespace: false)
      end

      it { is_expected.to be(false) }

      context 'and the group is already enrolled' do
        before do
          create(:knowledge_graph_enabled_namespace, namespace: group)
        end

        it { is_expected.to be(true) }
      end
    end
  end
end
