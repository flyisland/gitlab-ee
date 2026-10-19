# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::App, feature_category: :integrations do
  include_context 'with DingTalk application'

  it 'reads the single source of application credentials', :aggregate_failures do
    expect(described_class.app_id).to eq('ding-app')
    expect(described_class.app_secret).to eq('app-secret')
    expect(described_class.corp_id).to eq('ding-corp')
    expect(described_class.agent_id).to eq('123456')
    expect(described_class).to be_notifications_available
  end

  it 'disables notifications on SaaS' do
    allow(Gitlab).to receive(:com?).and_return(true)

    expect(described_class).not_to be_notifications_available
  end

  it 'requires a license' do
    stub_licensed_features(dingtalk_app_integration: false)

    expect(described_class).not_to be_notifications_available
  end

  it 'requires the feature flag' do
    stub_feature_flags(jh_dingtalk_app_notification: false)

    expect(described_class).not_to be_notifications_available
  end

  it 'requires the provider' do
    stub_omniauth_setting(providers: [])

    expect(described_class).not_to be_notifications_available
  end

  %w[corp_id agent_id].each do |key|
    it "requires #{key}" do
      dingtalk_provider['args'][key] = nil

      expect(described_class).not_to be_notifications_available
    end
  end

  it 'rejects third-party personal applications' do
    dingtalk_provider['args']['client_type'] = 'third_party_personal'

    expect(described_class).not_to be_notifications_available
  end
end
