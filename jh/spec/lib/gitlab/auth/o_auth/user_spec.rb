# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::OAuth::User, feature_category: :system_access do
  include JH::Gitlab::Auth::OAuth::AuthHash

  describe 'Feishu account resolution' do
    let_it_be(:user) { create(:user) }
    let(:auth) do
      OmniAuth::AuthHash.new(provider: 'feishu', uid: 'tenant:cli_app:ou_user',
        info: { name: user.name, email: user.email })
    end

    before do
      stub_omniauth_setting(allow_single_sign_on: true, auto_link_user: true, auto_link_ldap_user: true)
    end

    it 'does not register or automatically link an unbound user #security' do
      expect { expect(described_class.new(auth).gl_user).to be_nil }.not_to change { User.count }
      expect(user.identities.with_provider('feishu')).to be_empty
    end

    it 'resolves an existing bound identity' do
      create(:identity, user: user, provider: 'feishu', extern_uid: 'tenant:cli_app:ou_user')

      expect(described_class.new(auth).gl_user).to eq(user)
    end
  end

  describe '#build_new_user' do
    let(:extra_params) { {} }
    let(:oauth_temp_email) { "#{temporarily_email_prefix}@example.com" }

    subject(:oauth_user) do
      described_class.new(OmniAuth::AuthHash.new(info: { email: oauth_temp_email }), extra_params)
    end

    context 'for identity verification concerns', feature_category: :insider_threat do
      context 'when identity verification is enabled' do
        before do
          allow_next_instance_of(User) do |user|
            allow(user).to receive(:signup_identity_verification_enabled?).and_return(true)
          end
        end

        it 'still confirms the user' do
          expect(oauth_user.gl_user).to be_confirmed
        end
      end
    end
  end

  describe '#save with DingTalk' do
    include_context 'with DingTalk application'

    let_it_be(:user) { create(:user) }
    let(:uid) { 'old-openid' }
    let!(:identity) { create(:identity, user: user, provider: 'dingtalk', extern_uid: uid) }
    let(:oauth) do
      OmniAuth::AuthHash.new(
        provider: 'dingtalk', uid: uid, info: { name: user.name, email: user.email },
        extra: { raw_info: { openid: 'old-openid', userid: 'staff-123' } }
      )
    end

    before do
      stub_feature_flags(jh_dingtalk_app_notification: false)
    end

    it 'keeps existing openid logins and captures a separate recipient', :aggregate_failures do
      result = described_class.new(oauth).save

      expect(result).to eq(user)
      expect(identity.reload.extern_uid).to eq(uid)
      expect(Gitlab::Dingtalk::Recipient.for_user(user)).to eq('staff-123')
    end

    context 'with userid logins' do
      let(:uid) { 'staff-123' }

      it 'keeps existing userid logins and captures the recipient', :aggregate_failures do
        result = described_class.new(oauth).save

        expect(result).to eq(user)
        expect(identity.reload.extern_uid).to eq(uid)
        expect(Gitlab::Dingtalk::Recipient.for_user(user)).to eq('staff-123')
      end
    end

    it 'does not require a corporate userid to log in' do
      oauth['extra']['raw_info'].delete('userid')

      expect(described_class.new(oauth).save).to eq(user)
      expect(Gitlab::Dingtalk::Recipient.for_user(user)).to be_nil
    end
  end
end
