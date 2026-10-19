# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DingTalk notification opt-in', :js, feature_category: :integrations do
  let_it_be(:user, reload: true) { create(:user, :with_namespace) }

  let(:checkbox_label) { 'Also send notifications to my DingTalk account' }

  before do
    sign_in(user)
  end

  context 'when DingTalk delivery is available' do
    before do
      allow(::Gitlab::Dingtalk::App).to receive(:notifications_available?).and_return(true)
      visit profile_notifications_path
    end

    it 'is off by default, so binding alone does not start notifications' do
      expect(page).to have_unchecked_field(checkbox_label)
    end

    it 'saves the choice as soon as it is ticked' do
      check checkbox_label

      expect(page).to have_content('Notification settings saved')
      expect(::JH::Users::DingtalkNotification.enabled_for?(user)).to be(true)
    end

    # The input is visually hidden, so the label is the only thing a user can
    # click. `check` drives the input directly and passes even when a duplicate
    # DOM id has stolen the label's `for`, which leaves the control dead.
    it 'saves the choice when the visible label is clicked' do
      find('label', text: checkbox_label).click

      expect(page).to have_content('Notification settings saved')
      expect(::JH::Users::DingtalkNotification.enabled_for?(user)).to be(true)

      visit profile_notifications_path

      expect(page).to have_checked_field(checkbox_label)
    end
  end

  context 'when DingTalk delivery is not available' do
    before do
      allow(::Gitlab::Dingtalk::App).to receive(:notifications_available?).and_return(false)
      visit profile_notifications_path
    end

    it 'does not offer the setting' do
      expect(page).to have_content('Notifications')
      expect(page).to have_no_field(checkbox_label)
    end
  end
end
