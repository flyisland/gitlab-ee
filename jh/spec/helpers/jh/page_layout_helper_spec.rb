# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PageLayoutHelper do
  include StubConfiguration
  let(:tencent_url) { 'https://cdn-go.cn/aegis/aegis-sdk/latest/aegis.min.js' }

  before do
    stub_env('RUM_URL', tencent_url)
    allow(::Gitlab).to receive(:com?).and_return(true)
  end

  describe '#front_monitor_enabled?' do
    it 'rum is enable when ENV has RUM_URL' do
      expect(helper.front_monitor_enabled?).to be(true)
    end
  end
end
