# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FreeTrial::RemoveFreeTrialUserService, :saas, time_travel_to: '2026-06-01' do
  subject(:service) { described_class.new.execute }

  let_it_be(:admin, refind: true) { create(:user, :admin) }

  shared_examples 'does nothing' do
    it 'not remove user' do
      expect(::DeleteUserWorker).not_to receive(:perform_async)

      service
    end
  end

  context 'when not human user' do
    let_it_be(:user) { create(:user, :bot) }
    let_it_be(:attribute) do
      create(:user_custom_attribute, user: user,
        key: FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS, value: '2023-05-15 08:27:55 +0800')
    end

    it_behaves_like 'does nothing'
  end

  context 'when admin user' do
    let_it_be(:user_admin) { create(:user, :admin) }
    let_it_be(:attribute) do
      create(:user_custom_attribute, user: user_admin,
        key: FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS, value: '2023-05-15 08:27:55 +0800')
    end

    it_behaves_like 'does nothing'
  end

  context 'when not blocked user' do
    let_it_be(:user) { create(:user) }
    let_it_be(:attribute) do
      create(:user_custom_attribute, user: user,
        key: FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS, value: '2023-05-15 08:27:55 +0800')
    end

    it_behaves_like 'does nothing'
  end

  context 'when blocked user has no custom attributes' do
    let_it_be(:blocked_user) { create(:user, :blocked) }

    it_behaves_like 'does nothing'
  end

  context 'when blocked user has no block custom attribute' do
    let_it_be(:blocked_user) { create(:user, :blocked) }
    let_it_be(:attribute) do
      create(:user_custom_attribute, user: blocked_user, key: 'some key', value: 'some value')
    end

    it_behaves_like 'does nothing'
  end

  context 'when blocked user not overdue 3 years' do
    let_it_be(:blocked_user) { create(:user, :blocked) }
    let_it_be(:attribute) do
      create(:user_custom_attribute, user: blocked_user,
        key: FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS, value: '2025-11-15 08:27:55 +0800')
    end

    it_behaves_like 'does nothing'
  end

  context 'when blocked user overdue' do
    it 'invoke delete user worker' do
      blocked_user = create(:user, :blocked)
      create(:user_custom_attribute, user: blocked_user,
        key: FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS, value: '2023-05-15 08:27:55 +0800')

      expect(::DeleteUserWorker).to receive(:perform_async).with(admin.id, blocked_user.id, { hard_delete: true })
      service
    end
  end
end
