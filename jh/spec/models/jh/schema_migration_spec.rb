# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::SchemaMigration, feature_category: :database do
  describe '.all_versions' do
    subject(:schema_migration) { described_class.all_versions }

    it 'returns all versions' do
      allow(described_class).to receive(:order).with(:version).and_return([{ version: '2' }, { version: '1' }])

      expect(schema_migration).to eq %w[2 1]
    end
  end
end
