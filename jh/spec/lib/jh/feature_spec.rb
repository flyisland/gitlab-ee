# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Feature, stub_feature_flags: false, feature_category: :feature_flags do
  before do
    # reset Flipper AR-engine
    described_class.reset
  end

  describe 'Feature::Definition.default_enabled?' do
    it 'enables duo_workflow_cloud_connector_url by default' do
      expect(::Feature::Definition.default_enabled?(:duo_workflow_cloud_connector_url)).to be(true)
    end
  end

  describe '.flipper with ENV variable DISABLE_FF_PROCESS_MEMORY_CACHE' do
    subject(:adapter_delegate_sd_obj) { described_class.flipper.adapter.adapter }

    context 'with nil or false by default' do
      it 'uses process memory cache' do
        expect(adapter_delegate_sd_obj.class).to eq ::Flipper::Adapters::ActiveSupportCacheStore
        expect(adapter_delegate_sd_obj.instance_variable_get(:@ttl)).to eq(1.minute)
      end
    end

    context 'with true value to support E2E on JH staging' do
      before do
        stub_env('DISABLE_FF_PROCESS_MEMORY_CACHE', 'true')
      end

      it 'uses rails cache' do
        expect(adapter_delegate_sd_obj.class).to eq ::Feature::ActiveSupportCacheStoreAdapter
        expect(adapter_delegate_sd_obj.instance_variable_get(:@ttl)).to eq(1.hour)
      end
    end
  end
end
