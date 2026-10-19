# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Tracking::EventEligibilityChecker, feature_category: :service_ping do
  let(:checker) { described_class.new }

  describe '#eligible?' do
    context 'when snowplow is enabled' do
      before do
        stub_application_setting(snowplow_enabled: true, gitlab_product_usage_data_enabled: false)
      end

      it 'keeps upstream eligibility behavior for regular events' do
        expect(checker.eligible?('event_name')).to be(true)
      end
    end

    context 'when the event is an internal duo event' do
      before do
        stub_application_setting(snowplow_enabled: false, gitlab_product_usage_data_enabled: false)
      end

      it 'does not allow the event to fall back to the gitlab.net collectors' do
        expect(checker.eligible?('view_duo_agentic_not_available_empty_state')).to be(false)
      end
    end

    context 'when the event is an external duo event' do
      before do
        stub_application_setting(snowplow_enabled: false, gitlab_product_usage_data_enabled: false)
      end

      it 'does not allow the event to be sent' do
        expect(checker.eligible?('click_button', 'gitlab_ide_extension')).to be(false)
      end
    end
  end
end
