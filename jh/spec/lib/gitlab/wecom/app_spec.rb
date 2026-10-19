# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Wecom::App, feature_category: :integrations do
  let(:provider) do
    Gitlab::Configs::Options.build(
      'name' => 'wecom',
      'app_id' => 'ww_corp',
      'app_secret' => 'corp-secret',
      'args' => { 'agent_id' => '1000002' }
    )
  end

  before do
    stub_omniauth_setting(enabled: true, providers: [provider])
  end

  describe 'reading the application configuration' do
    it 'reads the credentials from the OmniAuth provider' do
      expect(described_class.corp_id).to eq('ww_corp')
      expect(described_class.corp_secret).to eq('corp-secret')
      expect(described_class.agent_id).to eq('1000002')
      expect(described_class).to be_configured
    end

    it 'falls back to the official API host' do
      expect(described_class.api_site).to eq(OmniAuth::Strategies::Wecom::API_SITE)
    end

    it 'is not configured when the provider is absent' do
      stub_omniauth_setting(enabled: true, providers: [])

      expect(described_class).not_to be_configured
      expect(described_class.corp_id).to be_nil
    end
  end

  describe '.notifications_available?' do
    before do
      stub_licensed_features(wecom_app_integration: true)
      stub_feature_flags(jh_wecom_app_notification: true)
      allow(::Gitlab).to receive(:com?).and_return(false)
    end

    it 'is available once every gate is open' do
      expect(described_class).to be_notifications_available
    end

    it 'stays closed on SaaS' do
      allow(::Gitlab).to receive(:com?).and_return(true)

      expect(described_class).not_to be_notifications_available
    end

    it 'stays closed without the licence' do
      stub_licensed_features(wecom_app_integration: false)

      expect(described_class).not_to be_notifications_available
    end

    it 'stays closed behind the feature flag' do
      stub_feature_flags(jh_wecom_app_notification: false)

      expect(described_class).not_to be_notifications_available
    end

    it 'stays closed when the application is not configured' do
      stub_omniauth_setting(enabled: true, providers: [])

      expect(described_class).not_to be_notifications_available
    end
  end
end
