# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Sbom::DependencyAggregationType, feature_category: :dependency_management do
  it 'implements the DependencyInterface interface' do
    expect(described_class.interfaces).to include(Types::Sbom::DependencyInterface)
  end

  it { expect(described_class.graphql_name).to eq('DependencyAggregation') }

  describe '#licenses' do
    let_it_be(:group) { create(:group) }

    let(:license_data) { [{ 'spdx_identifier' => 'MIT', 'name' => 'MIT' }] }
    let(:object) do
      instance_double(
        ::Sbom::Occurrence,
        licenses: license_data,
        purl_type: 'gem',
        component_name: 'rails',
        version: '7.0'
      )
    end

    let(:context) { { group: group } }
    let(:type_instance) do
      instance = described_class.allocate
      instance.instance_variable_set(:@object, object)
      instance.instance_variable_set(:@context, context)
      instance
    end

    context 'when experiment is not enabled for the group' do
      before do
        allow(Security::LicenseOverrideApplicator).to receive(:experiment_enabled_for_group?)
          .with(group).and_return(false)
      end

      it 'returns original licenses' do
        expect(type_instance.licenses).to eq(license_data)
      end
    end

    context 'when no group is in context' do
      let(:context) { {} }

      it 'returns original licenses' do
        expect(type_instance.licenses).to eq(license_data)
      end
    end

    context 'when experiment is enabled and overrides are present' do
      let(:overridden) { [{ 'spdx_identifier' => 'Apache-2.0', 'name' => 'Apache-2.0' }] }
      let(:applicator) { instance_double(Security::LicenseOverrideApplicator, overrides?: true) }

      before do
        allow(Security::LicenseOverrideApplicator).to receive(:experiment_enabled_for_group?)
          .with(group).and_return(true)
        allow(Security::LicenseOverrideApplicator).to receive(:new_for_group).with(group).and_return(applicator)
        allow(applicator).to receive(:apply).and_return(overridden)
      end

      it 'applies group license overrides' do
        expect(type_instance.licenses).to eq(overridden)
      end
    end

    context 'when experiment is enabled but applicator has no overrides' do
      let(:applicator) { instance_double(Security::LicenseOverrideApplicator, overrides?: false) }

      before do
        allow(Security::LicenseOverrideApplicator).to receive(:experiment_enabled_for_group?)
          .with(group).and_return(true)
        allow(Security::LicenseOverrideApplicator).to receive(:new_for_group).with(group).and_return(applicator)
      end

      it 'returns the input licenses unchanged' do
        expect(type_instance.licenses).to eq(license_data)
      end
    end

    context 'when occurrence has no purl_type' do
      let(:applicator) { instance_double(Security::LicenseOverrideApplicator, overrides?: true) }
      let(:object) do
        instance_double(
          ::Sbom::Occurrence,
          licenses: license_data,
          purl_type: nil,
          component_name: 'rails',
          version: '7.0'
        )
      end

      before do
        allow(Security::LicenseOverrideApplicator).to receive(:experiment_enabled_for_group?)
          .with(group).and_return(true)
        allow(Security::LicenseOverrideApplicator).to receive(:new_for_group).with(group).and_return(applicator)
      end

      it 'returns the input licenses unchanged' do
        expect(type_instance.licenses).to eq(license_data)
      end
    end

    context 'when occurrence has no version' do
      let(:overridden) { [{ 'spdx_identifier' => 'Apache-2.0', 'name' => 'Apache-2.0' }] }
      let(:applicator) { instance_double(Security::LicenseOverrideApplicator, overrides?: true) }
      let(:object) do
        instance_double(
          ::Sbom::Occurrence,
          licenses: license_data,
          purl_type: 'gem',
          component_name: 'rails',
          version: nil
        )
      end

      before do
        allow(Security::LicenseOverrideApplicator).to receive(:experiment_enabled_for_group?)
          .with(group).and_return(true)
        allow(Security::LicenseOverrideApplicator).to receive(:new_for_group).with(group).and_return(applicator)
        allow(applicator).to receive(:apply).with(license_data, purl: 'pkg:gem/rails').and_return(overridden)
      end

      it 'builds a versionless purl and applies overrides' do
        expect(type_instance.licenses).to eq(overridden)
      end
    end

    context 'when object has no licenses' do
      let(:object) { instance_double(::Sbom::Occurrence, licenses: nil) }

      it 'returns an empty array' do
        expect(type_instance.licenses).to eq([])
      end
    end
  end
end
