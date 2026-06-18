# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AI Settings', feature_category: :ai_abstraction_layer do
  subject(:load_file) { load Rails.root.join('ee/db/fixtures/production/041_create_ai_settings.rb') }

  context 'when creating an AI settings record with defaults' do
    let(:ai_gateway_url) { nil }
    let(:expanded_ai_logging) { false }

    before do
      stub_env('AI_GATEWAY_URL', ai_gateway_url)
      stub_feature_flags(expanded_ai_logging: expanded_ai_logging)
    end

    shared_examples 'creates a single AI settings record' do
      it 'creates a record with expected defaults' do
        load_file

        setting = Ai::Setting.first
        expect(setting.ai_gateway_url).to eq(ai_gateway_url)
        expect(setting.enabled_instance_verbose_ai_logs).to eq(expanded_ai_logging)
      end
    end

    context 'when env and feature flag are not set' do
      it_behaves_like 'creates a single AI settings record'
    end

    context 'when env and feature flag are set' do
      let(:ai_gateway_url) { 'http://ai-gateway.test' }
      let(:expanded_ai_logging) { true }

      it_behaves_like 'creates a single AI settings record'
    end
  end

  it 'does not raise when the record already exists' do
    Ai::Setting.instance

    expect { load_file }.not_to raise_error
    expect(Ai::Setting.count).to eq 1
  end
end
