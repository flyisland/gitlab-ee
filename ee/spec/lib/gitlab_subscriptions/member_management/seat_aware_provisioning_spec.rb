# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::MemberManagement::SeatAwareProvisioning, feature_category: :seat_cost_management do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  let(:test_class) do
    Class.new do
      include GitlabSubscriptions::MemberManagement::SeatAwareProvisioning
    end
  end

  let(:instance) { test_class.new }

  describe '#calculate_adjusted_access_level' do
    let(:desired_access) { Gitlab::Access::DEVELOPER }
    let(:invitee) { user }
    let(:expected_user_identifier) { user.id }
    let(:expected_user_id_in_log) { user.id }

    subject(:result) do
      instance.calculate_adjusted_access_level(group, invitee, desired_access)
    end

    before do
      allow(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
        .to receive(:block_seat_overages?).with(group).and_return(true)
      allow(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
        .to receive(:seats_available_for?)
    end

    shared_examples 'feature flag disabled behavior' do
      it 'returns desired access level unchanged' do
        expect(result).to eq(desired_access)
        expect(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
          .not_to have_received(:seats_available_for?)
      end
    end

    shared_examples 'seats available behavior' do
      before do
        allow(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
          .to receive(:seats_available_for?).and_return(true)
      end

      it 'returns desired access level' do
        expect(result).to eq(desired_access)
        expect(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
          .to have_received(:seats_available_for?)
          .with(group, [expected_user_identifier], desired_access, nil)
      end

      it 'does not log access level adjustment' do
        allow(Gitlab::AppLogger).to receive(:info)

        result

        expect(Gitlab::AppLogger).not_to have_received(:info).with(
          hash_including(message: 'Group membership access level adjusted due to BSO seat limits')
        )
      end
    end

    shared_examples 'seats not available behavior' do
      before do
        allow(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
          .to receive(:seats_available_for?).and_return(false)
      end

      it 'returns minimal access' do
        expect(result).to eq(Gitlab::Access::MINIMAL_ACCESS)
        expect(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
          .to have_received(:seats_available_for?)
          .with(group, [expected_user_identifier], desired_access, nil)
      end

      it 'logs the access level adjustment' do
        allow(Gitlab::AppLogger).to receive(:info)

        result

        expect(Gitlab::AppLogger).to have_received(:info).with(
          hash_including(
            message: 'Group membership access level adjusted due to BSO seat limits',
            group_id: group.id,
            group_path: group.full_path,
            user_id: expected_user_id_in_log,
            requested_access_level: desired_access,
            adjusted_access_level: Gitlab::Access::MINIMAL_ACCESS,
            feature_flag: 'bso_minimal_access_fallback'
          )
        )
      end

      it 'logs the access level adjustment with extra parameters' do
        allow(Gitlab::AppLogger).to receive(:info)

        instance.calculate_adjusted_access_level(group, user, desired_access, { scim_group_uid: 'test-uid' })

        expect(Gitlab::AppLogger).to have_received(:info).with(
          hash_including(scim_group_uid: 'test-uid')
        )
      end
    end

    shared_examples 'BSO feature flag enabled behavior' do
      context 'when seats are available' do
        include_examples 'seats available behavior'
      end

      context 'when seats are not available' do
        include_examples 'seats not available behavior'
      end
    end

    context 'when on SaaS', :saas do
      context 'when bso_minimal_access_fallback feature flag is disabled for the group' do
        before do
          stub_feature_flags(bso_minimal_access_fallback: false)
        end

        include_examples 'feature flag disabled behavior'
      end

      context 'when bso_minimal_access_fallback feature flag is enabled for the group' do
        before do
          stub_feature_flags(bso_minimal_access_fallback: group.root_ancestor)
        end

        include_examples 'BSO feature flag enabled behavior'
      end
    end

    context 'when on self-managed' do
      context 'when bso_minimal_access_fallback feature flag is disabled instance-wide' do
        before do
          stub_feature_flags(bso_minimal_access_fallback: false)
        end

        include_examples 'feature flag disabled behavior'
      end

      context 'when bso_minimal_access_fallback feature flag is enabled instance-wide' do
        before do
          stub_feature_flags(bso_minimal_access_fallback: true)
        end

        include_examples 'BSO feature flag enabled behavior'
      end
    end

    context 'when BSO is not enabled' do
      before do
        allow(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
          .to receive(:block_seat_overages?).with(group).and_return(false)
      end

      it 'returns desired access level unchanged' do
        expect(result).to eq(desired_access)
        expect(GitlabSubscriptions::MemberManagement::BlockSeatOverages)
          .not_to have_received(:seats_available_for?)
      end
    end
  end

  describe '#track_ma_provisioning_event', :clean_gitlab_redis_shared_state, :freeze_time do
    let(:root_namespace) { group }
    let(:user_identifier) { user.id }
    let(:current_date) { Date.current.iso8601 }
    let(:redis_root_groups_key) { "seat_aware_provisioning:group:{#{current_date}}" }
    let(:redis_users_key) { "seat_aware_provisioning:group:#{root_namespace.id}:{#{current_date}}" }
    let(:redis_instance_key) { "seat_aware_provisioning:instance:{#{current_date}}" }

    subject(:track_event) { instance.track_ma_provisioning_event(root_namespace, user_identifier) }

    context 'when invitee identifier is nil' do
      let(:user_identifier) { nil }

      it 'does not write to cache' do
        track_event

        ::Gitlab::Redis::SharedState.with do |redis|
          expect(redis.exists?(redis_instance_key)).to be false
        end
      end
    end

    context 'when bso_minimal_access_fallback feature flag is disabled' do
      before do
        stub_feature_flags(bso_minimal_access_fallback: false)
      end

      it 'does not write to cache' do
        track_event

        ::Gitlab::Redis::SharedState.with do |redis|
          expect(redis.exists?(redis_instance_key)).to be false
        end
      end
    end

    context 'when on self-managed' do
      it 'writes to instance scoped cache' do
        track_event

        ::Gitlab::Redis::SharedState.with do |redis|
          expect(redis.sismember(redis_instance_key, user_identifier.to_s)).to be true
        end
      end

      it 'does not write to namespace scoped caches' do
        track_event

        ::Gitlab::Redis::SharedState.with do |redis|
          expect(redis.sismember(redis_root_groups_key, root_namespace.id.to_s)).to be false
          expect(redis.sismember(redis_users_key, user_identifier.to_s)).to be false
        end
      end
    end

    context 'when on SaaS', :saas do
      it 'writes to namespace scoped caches' do
        track_event

        ::Gitlab::Redis::SharedState.with do |redis|
          expect(redis.sismember(redis_root_groups_key, root_namespace.id.to_s)).to be true
          expect(redis.sismember(redis_users_key, user_identifier.to_s)).to be true
        end
      end

      it 'does not write to instance scoped cache' do
        track_event

        ::Gitlab::Redis::SharedState.with do |redis|
          expect(redis.sismember(redis_instance_key, user_identifier.to_s)).to be false
        end
      end
    end
  end
end
