# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OmniAuth::Strategies::Dingtalk do # rubocop:disable RSpec/SpecFilePathFormat
  let(:strategy) { described_class.new(nil) }
  let(:user_info) { { 'userid' => '123456789', 'openid' => 'test-openid' } }

  before do
    allow(strategy).to receive(:user_info).and_return(user_info)
  end

  describe '#uid' do
    context 'when ff_dingtalk_oauth_use_userid feature is enabled' do
      it 'returns the userid' do
        expect(strategy.uid).to eq('123456789')
      end
    end

    context 'when ff_dingtalk_oauth_use_userid feature is disabled' do
      before do
        stub_feature_flags(ff_dingtalk_oauth_use_userid: false)
      end

      it 'returns the openid' do
        expect(strategy.uid).to eq('test-openid')
      end
    end
  end
end
