# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::UnblockService do
  let_it_be(:current_user) { create(:user, :admin) }

  let(:user) { create(:user, :blocked) }

  subject(:service) { described_class.new(current_user).execute(user) }

  describe '#execute' do
    context 'when not saas' do
      it 'not update free trial blocked attribute' do
        allow(Gitlab).to receive(:com?).and_return(false)
        attribute = user.custom_attributes.create(key: ::FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS,
          value: 'some date')

        service

        expect(attribute.reset).to have_attributes(key: ::FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS,
          value: 'some date')
      end
    end

    context 'when saas' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      it 'create unblock attribute when unblock normal blocked' do
        blocked = user.custom_attributes.create(key: UserCustomAttribute::BLOCKED_BY, value: 'some date')

        service

        expect(blocked.reset).to have_attributes(blocked.attributes)
        expect(user.custom_attributes.last).to have_attributes(key: UserCustomAttribute::UNBLOCKED_BY)
      end

      it 'expire previous free trial attribute when unblock free trial blocked' do
        user.custom_attributes.create(key: 'free_trial_left_days', value: '1')
        free_trial_attribute = user.custom_attributes.create(
          key: ::FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS, value: 'some date')

        service

        expect(free_trial_attribute.reset).to have_attributes(key: "blocked_by_free_trial_ends/some date",
          value: 'expired')
        expect(user.custom_attributes.last).to have_attributes(key: UserCustomAttribute::UNBLOCKED_BY)
        expect(user.custom_attributes.by_key('free_trial_left_days').exists?).to be_falsey
      end
    end
  end
end
