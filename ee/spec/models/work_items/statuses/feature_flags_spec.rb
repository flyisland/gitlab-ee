# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Statuses::FeatureFlags, feature_category: :team_planning do
  let_it_be(:namespace) { create(:group) }

  describe '.status_flag_gated_base_types' do
    it 'includes epic' do
      expect(described_class.status_flag_gated_base_types).to include('epic')
    end

    it 'does not include always-enabled types' do
      expect(described_class.status_flag_gated_base_types).not_to include('issue', 'task')
    end
  end

  describe '.status_enabled_for_base_type?' do
    context 'with a non-flag-gated base type' do
      it 'is always enabled, even without a namespace' do
        expect(described_class.status_enabled_for_base_type?('issue', namespace)).to be(true)
        expect(described_class.status_enabled_for_base_type?('task', nil)).to be(true)
      end
    end

    context 'with a flag-gated base type' do
      it 'is enabled when the flag is on for the namespace' do
        expect(described_class.status_enabled_for_base_type?('epic', namespace)).to be(true)
      end

      it 'is disabled when the flag is off for the namespace' do
        stub_feature_flags(work_item_status_for_epics: false)

        expect(described_class.status_enabled_for_base_type?('epic', namespace)).to be(false)
      end

      it 'is disabled when the namespace cannot be resolved' do
        expect(described_class.status_enabled_for_base_type?('epic', nil)).to be(false)
      end
    end
  end
end
