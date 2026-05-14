# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::Instrumentations::DuoAgentPlatformEnabledMetric, feature_category: :service_ping do
  let(:ai_setting) { ::Ai::Setting.instance }

  context 'when duo agent platform is disabled' do
    before do
      ai_setting.update!(feature_settings: { duo_agent_platform_enabled: false })
    end

    it_behaves_like 'a correct instrumented metric value', { time_frame: 'none' } do
      let(:expected_value) { false }
    end
  end

  context 'when duo agent platform is enabled' do
    before do
      ai_setting.update!(feature_settings: { duo_agent_platform_enabled: true })
    end

    it_behaves_like 'a correct instrumented metric value', { time_frame: 'none' } do
      let(:expected_value) { true }
    end
  end
end
