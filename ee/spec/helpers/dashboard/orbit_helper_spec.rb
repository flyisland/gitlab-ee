# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::OrbitHelper, feature_category: :knowledge_graph do
  describe '#orbit_app_data' do
    it 'includes router_base' do
      expect(helper.orbit_app_data).to include(router_base: dashboard_orbit_path)
    end
  end

  describe '#orbit_page_label' do
    it 'returns Data Explorer by default' do
      allow(helper).to receive(:params).and_return({})

      expect(helper.orbit_page_label).to eq('Data Explorer')
    end

    it 'returns Schema for schema route' do
      allow(helper).to receive(:params).and_return({ vueroute: 'schema' })

      expect(helper.orbit_page_label).to eq('Schema')
    end

    it 'returns Configuration for configuration route' do
      allow(helper).to receive(:params).and_return({ vueroute: 'configuration' })

      expect(helper.orbit_page_label).to eq('Configuration')
    end
  end
end
