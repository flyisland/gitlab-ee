# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integration do
  describe '.integration_names' do
    subject { described_class.integration_names }

    before do
      stub_application_setting(
        dingtalk_integration_enabled: true,
        dingtalk_app_key: "dingtalk_app_key",
        dingtalk_corpid: "dingtalk_corpid",
        dingtalk_app_secret: "dingtalk_app_secret",
        feishu_integration_enabled: true,
        feishu_app_key: "feishu_app_key",
        feishu_app_secret: "feishu_app_secret"
      )
    end

    it 'contains expected integration names' do
      is_expected.to include('dingtalk')
      is_expected.to include('feishu')
      is_expected.to include('feishu_bot')
      is_expected.to include('ones')
      is_expected.to include('ligaai')
      is_expected.to include('wecom')
    end

    context 'with third party integrations feature flag disabled' do
      before do
        stub_feature_flags(wecom_integration: false)
      end

      it "does'nt contain expected integration names" do
        is_expected.not_to include('wecom')
      end
    end
  end
end
