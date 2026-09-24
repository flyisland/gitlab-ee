# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../scripts/internal_events/product_group_renamer'

RSpec.describe ProductGroupRenamer, feature_category: :service_ping do
  let(:renamer) { described_class.new(schema_path, definitions_glob) }

  context 'with real definitions', :aggregate_failures do
    let(:schema_path) { PRODUCT_GROUPS_SCHEMA_PATH }
    # override definitions_glob in upstream spec
    let(:definitions_glob) { "{ee/,jh/,}config/{metrics/*,events}/*.yml" }

    it 'reads all definitions files' do
      allow(File).to receive(:read).and_call_original

      Gitlab::Tracking::EventDefinition.definitions.each do |event_definition|
        expect(File).to receive(:read).with(event_definition.path)
        expect(File).not_to receive(:write).with(event_definition.path)
      end

      Gitlab::Usage::MetricDefinition.definitions.values.map(&:path).uniq.each do |metric_definition_path|
        expect(File).to receive(:read).with(metric_definition_path)
        expect(File).not_to receive(:write).with(metric_definition_path)
      end

      renamer.rename_product_group('old_name', 'new_name')
    end
  end
end
