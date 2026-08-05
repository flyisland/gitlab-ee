# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Authz::ArtifactRegistry::Roles, feature_category: :system_access do
  describe '.uuid_for' do
    it 'returns the UUID for a known role' do
      expect(described_class.uuid_for(:artifact_viewer)).to eq('019ed9d4-7d53-7b5c-8653-1ceac0c48b14')
    end

    it 'is case-insensitive' do
      expect(described_class.uuid_for('ARTIFACT_VIEWER')).to eq(described_class.uuid_for(:artifact_viewer))
    end

    it 'returns nil for an unknown role' do
      expect(described_class.uuid_for(:not_a_role)).to be_nil
    end
  end
end
