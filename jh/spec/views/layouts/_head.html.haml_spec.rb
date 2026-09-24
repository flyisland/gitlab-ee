# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/_head' do
  include StubConfiguration
  let(:tencent_url) { 'https://cdn-go.cn/aegis/aegis-sdk/latest/aegis.min.js' }

  before do
    stub_env('RUM_URL', tencent_url)
  end

  context 'when it is saas', :saas do
    it 'add Tencent RUM Javascript' do
      render partial: 'layouts/head', formats: [:html]

      expect(rendered).to match('https://cdn-go.cn/aegis/aegis-sdk/latest/aegis.min.js')
    end
  end
end
