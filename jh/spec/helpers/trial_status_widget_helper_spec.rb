# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialStatusWidgetHelper, :saas, feature_category: :user_profile do
  describe '#trial_days_data' do
    let(:user) { create(:user) }
    let(:days_left) { 7 }

    subject(:data) { helper.account_trial_notification_data }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      UserCustomAttribute.upsert_custom_attributes([user_id: user.id, key: :free_trial_left_days, value: days_left])
    end

    it 'return days left and updated time' do
      expect(data[:days_left]).to eq(days_left)
      expect(data[:updated_at]).to be_a String
    end

    it 'return empty hash when no current user' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(data).to eq({})
    end
  end
end
