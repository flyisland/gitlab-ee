# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Feishu notification opt-in', :js, feature_category: :integrations do
  let_it_be(:user, reload: true) { create(:user, :with_namespace) }

  let(:checkbox_label) { 'Also send notifications to my Feishu account' }

  before do
    sign_in(user)
  end

  context 'when Feishu delivery is available' do
    before do
      allow(::Gitlab::Feishu::App).to receive(:notifications_available?).and_return(true)
      visit profile_notifications_path
    end

    it 'is off by default, so binding alone does not start notifications' do
      expect(page).to have_unchecked_field(checkbox_label)
    end

    it 'saves the choice as soon as it is ticked' do
      check checkbox_label

      expect(page).to have_content('Notification settings saved')
      expect(::JH::Users::FeishuNotification.enabled_for?(user)).to be(true)
    end

    # The input is visually hidden, so the label is the only thing a user can
    # click. `check` drives the input directly and passes even when a duplicate
    # DOM id has stolen the label's `for`, which leaves the control dead.
    it 'saves the choice when the visible label is clicked' do
      find('label', text: checkbox_label).click

      expect(page).to have_content('Notification settings saved')
      expect(::JH::Users::FeishuNotification.enabled_for?(user)).to be(true)

      visit profile_notifications_path

      expect(page).to have_checked_field(checkbox_label)
    end

    context 'when notifications are already enabled' do
      before do
        ::JH::Users::FeishuNotification.set(user, true)
        visit profile_notifications_path
      end

      it 'saves the opt-out when unchecked' do
        uncheck checkbox_label

        expect(page).to have_content('Notification settings saved')
        expect(::JH::Users::FeishuNotification.enabled_for?(user)).to be(false)
      end
    end
  end

  context 'when Feishu delivery is not available' do
    before do
      allow(::Gitlab::Feishu::App).to receive(:notifications_available?).and_return(false)
      visit profile_notifications_path
    end

    it 'does not offer the setting' do
      expect(page).not_to have_content(checkbox_label)
    end
  end
end
