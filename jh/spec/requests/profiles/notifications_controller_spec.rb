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

    # The form posts a hidden 0 next to the checkbox, so an opt-out arrives as an
    # explicit value. Absence means a different form posted, not an opt-out.
    it 'saves the opt-out' do
      ::JH::Users::WecomNotification.set(user, true)

      update_opt_in(false)

      expect(opted_in?).to be(false)
    end

    it 'preserves the choice when updating the notification email' do
      ::JH::Users::WecomNotification.set(user, true)

      put profile_notifications_path, params: {
        user: { notification_email: user.email }
      }

      expect(opted_in?).to be(true)
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

  describe 'Feishu preferences' do
    let(:provider) do
      Gitlab::Configs::Options.build(name: 'feishu', app_id: 'cli_app', app_secret: 'secret',
        args: { tenant_key: 'tenant' })
    end

    before do
      stub_omniauth_setting(enabled: true, providers: [provider])
      stub_licensed_features(feishu_app_integration: true)
      allow(Gitlab).to receive(:com?).and_return(false)
    end

    def update_feishu(value)
      put profile_notifications_path, params: { user: { feishu_notifications_enabled: value } }
    end

    it 'saves and clears the choice' do
      update_feishu(true)
      expect(JH::Users::FeishuNotification.enabled_for?(user)).to be(true)
      update_feishu(false)
      expect(JH::Users::FeishuNotification.enabled_for?(user)).to be(false)
    end

    it 'does not let another user update this preference' do
      other_user = create(:user)
      put profile_notifications_path, params: { user: { id: other_user.id, feishu_notifications_enabled: true } }

      expect(JH::Users::FeishuNotification.enabled_for?(other_user)).to be(false)
    end

    it 'preserves the choice when updating the notification email' do
      JH::Users::FeishuNotification.set(user, true)

      put profile_notifications_path, params: { user: { notification_email: user.email } }

      expect(JH::Users::FeishuNotification.enabled_for?(user)).to be(true)
    end

    it 'requires authentication' do
      sign_out(user)
      update_feishu(true)

      expect(JH::Users::FeishuNotification.enabled_for?(user)).to be(false)
    end

    [:flag, :license, :saas, :configuration].each do |gate|
      context "when the #{gate} gate is closed" do
        before do
          case gate
          when :flag then stub_feature_flags(jh_feishu_app_notification: false)
          when :license then stub_licensed_features(feishu_app_integration: false)
          when :saas then allow(Gitlab).to receive(:com?).and_return(true)
          when :configuration then stub_omniauth_setting(enabled: true, providers: [])
          end
        end

        it 'refuses a forged opt-in request #security' do
          update_feishu(true)

          expect(JH::Users::FeishuNotification.enabled_for?(user)).to be(false)
        end

        it 'preserves the stored choice while delivery is disabled' do
          JH::Users::FeishuNotification.set(user, true)
          update_feishu(false)

          expect(JH::Users::FeishuNotification.enabled_for?(user)).to be(true)
        end
      end
    end
  end

  context 'with DingTalk notifications' do
    include_context 'with DingTalk application'

    it 'defaults to off' do
      expect(JH::Users::DingtalkNotification.enabled_for?(user)).to be(false)
    end

    it 'saves the preference independently of WeCom' do
      put profile_notifications_path, params: { user: { dingtalk_notifications_enabled: '1' } }

      expect(JH::Users::DingtalkNotification.enabled_for?(user)).to be(true)
    end

    it 'saves an unchecked preference' do
      JH::Users::DingtalkNotification.set(user, true)
      put profile_notifications_path, params: { user: { dingtalk_notifications_enabled: '0' } }

      expect(JH::Users::DingtalkNotification.enabled_for?(user)).to be(false)
    end

    it 'preserves the preference when a different form is submitted' do
      JH::Users::DingtalkNotification.set(user, true)
      put profile_notifications_path, params: { user: { notification_email: user.email } }

      expect(JH::Users::DingtalkNotification.enabled_for?(user)).to be(true)
    end

    it 'rejects a forged preference while disabled' do
      stub_feature_flags(jh_dingtalk_app_notification: false)
      put profile_notifications_path, params: { user: { dingtalk_notifications_enabled: '1' } }

      expect(JH::Users::DingtalkNotification.enabled_for?(user)).to be(false)
    end

    it 'preserves an existing opt-in while disabled' do
      JH::Users::DingtalkNotification.set(user, true)
      stub_feature_flags(jh_dingtalk_app_notification: false)
      put profile_notifications_path, params: { user: { notified_of_own_activity: true } }

      expect(JH::Users::DingtalkNotification.enabled_for?(user)).to be(true)
    end

    it 'rejects a forged preference without a license' do
      stub_licensed_features(dingtalk_app_integration: false)
      put profile_notifications_path, params: { user: { dingtalk_notifications_enabled: '1' } }

      expect(JH::Users::DingtalkNotification.enabled_for?(user)).to be(false)
    end
  end
end
