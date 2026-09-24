# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Profiles::NotificationsController, feature_category: :integrations do
  let_it_be(:user, reload: true) { create(:user) }

  before do
    sign_in(user)
  end

  def update_opt_in(enabled)
    put profile_notifications_path, params: {
      user: {
        notified_of_own_activity: user.notified_of_own_activity,
        wecom_notifications_enabled: enabled
      }
    }
  end

  def opted_in?
    ::JH::Users::WecomNotification.enabled_for?(user)
  end

  context 'when WeCom delivery is available' do
    before do
      allow(::Gitlab::Wecom::App).to receive(:notifications_available?).and_return(true)
    end

    it 'saves the opt-in' do
      update_opt_in(true)

      expect(opted_in?).to be(true)
    end

    # An unticked checkbox posts nothing at all, so the parameter's absence is
    # the opt-out and has to be stored as one.
    it 'reads a missing parameter as an opt-out' do
      ::JH::Users::WecomNotification.set(user, true)

      put profile_notifications_path, params: {
        user: { notified_of_own_activity: user.notified_of_own_activity }
      }

      expect(opted_in?).to be(false)
    end
  end

  context 'when WeCom delivery is not available' do
    before do
      allow(::Gitlab::Wecom::App).to receive(:notifications_available?).and_return(false)
    end

    # The parameter is not merely hidden in the UI: the controller refuses to
    # store it, so a crafted request cannot switch on a channel the instance
    # does not offer.
    it 'ignores the parameter' do
      update_opt_in(true)

      expect(opted_in?).to be(false)
    end
  end
end
