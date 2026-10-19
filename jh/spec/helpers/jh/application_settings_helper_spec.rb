# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::ApplicationSettingsHelper do
  describe '#visible_attributes' do
    context 'with content_validation' do
      it 'return content validation fields' do
        expect(helper.visible_attributes).to include(:content_validation_endpoint_enabled,
          :content_validation_endpoint_url,
          :content_validation_api_key)
      end
    end

    context 'for dingtalk integration' do
      context 'when enable dingtalk_integration' do
        it 'return dingtalk integration fields' do
          expect(helper.visible_attributes).to include(:dingtalk_integration_enabled,
            :dingtalk_corpid,
            :dingtalk_app_key,
            :dingtalk_app_secret)
        end
      end
    end

    context 'for feishu integration' do
      context 'when enable feishu_integration' do
        it 'return dingtalk integration fields' do
          expect(helper.visible_attributes).to include(:feishu_integration_enabled,
            :feishu_app_key,
            :feishu_app_secret)
        end
      end
    end
  end
end
