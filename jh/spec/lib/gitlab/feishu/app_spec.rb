# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::App, feature_category: :integrations do
  let(:provider) do
    Gitlab::Configs::Options.build(
      'name' => 'feishu',
      'app_id' => 'cli_app',
      'app_secret' => 'corp-secret',
      'args' => { 'tenant_key' => 'tenant' }
    )
  end

  before do
    stub_omniauth_setting(enabled: true, providers: [provider])
  end

  describe 'reading the application configuration' do
    it 'reads the credentials from the OmniAuth provider' do
      expect(described_class.app_id).to eq('cli_app')
      expect(described_class.app_secret).to eq('corp-secret')
      expect(described_class.tenant_key).to eq('tenant')
      expect(described_class).to be_configured
    end

    it 'falls back to the official API host' do
      expect(described_class.api_site).to eq(OmniAuth::Strategies::Feishu::API_SITE)
    end

    it 'is not configured when the provider is absent' do
      stub_omniauth_setting(enabled: true, providers: [])

      expect(described_class).not_to be_configured
      expect(described_class.app_id).to be_nil
    end
  end

  describe '.notifications_available?' do
    before do
      stub_licensed_features(feishu_app_integration: true)
      stub_feature_flags(jh_feishu_app_notification: true)
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
      stub_licensed_features(feishu_app_integration: false)

      expect(described_class).not_to be_notifications_available
    end

    it 'stays closed behind the feature flag' do
      stub_feature_flags(jh_feishu_app_notification: false)

      expect(described_class).not_to be_notifications_available
    end

    it 'stays closed when the application is not configured' do
      stub_omniauth_setting(enabled: true, providers: [])

      expect(described_class).not_to be_notifications_available
    end
  end
end
