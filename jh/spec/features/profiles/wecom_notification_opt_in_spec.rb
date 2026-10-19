# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'WeCom notification opt-in', :js, feature_category: :integrations do
  # The profile layout renders an alert off current_user.namespace, and the
  # factory only builds one for specs on the shim allowlist.
  let_it_be(:user, reload: true) { create(:user, :with_namespace) }

  let(:checkbox_label) { 'Also send notifications to my WeCom account' }

  before do
    sign_in(user)
  end

  context 'when WeCom delivery is available' do
    before do
      allow(::Gitlab::Wecom::App).to receive(:notifications_available?).and_return(true)
      visit profile_notifications_path
    end

    it 'is off by default, so binding alone does not start notifications' do
      expect(page).to have_unchecked_field(checkbox_label)
    end

    # The page has no save button; ticking has to submit the form by itself.
    it 'saves the choice as soon as it is ticked' do
      check checkbox_label

      expect(page).to have_content('Notification settings saved')
      expect(::JH::Users::WecomNotification.enabled_for?(user)).to be(true)
    end
  end

  context 'when WeCom delivery is not available' do
    before do
      allow(::Gitlab::Wecom::App).to receive(:notifications_available?).and_return(false)
      visit profile_notifications_path
    end

    it 'does not offer the setting' do
      expect(page).not_to have_content(checkbox_label)
    end
  end
end
