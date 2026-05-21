# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyManagement::SecurityUpdate::JobBuilder, feature_category: :dependency_management do
  let_it_be(:namespace) { create(:namespace, path: 'my-group') }
  let_it_be(:project) { create(:project, path: 'my-project', namespace: namespace) }

  let(:sbom_component) { create(:sbom_component, purl_type: 'gem', name: 'rails') }

  let(:sbom_occurrence) do
    create(:sbom_occurrence,
      project: project,
      package_manager: 'bundler',
      input_file_path: 'Gemfile',
      component: sbom_component
    ).tap { |o| o.component_version&.update!(version: '6.0.0') }
  end

  let(:vulnerability) do
    create(:vulnerability, :with_finding, :detected, project: project, report_type: :dependency_scanning)
  end

  let(:request) do
    DependencyManagement::SecurityUpdate::Request.new(
      sbom_occurrence: sbom_occurrence,
      vulnerability: vulnerability
    )
  end

  subject(:builder) { described_class.new(request: request, project: project) }

  describe '#build' do
    it 'returns the expected job configuration hash' do
      expect(builder.build).to eq(
        'package-manager' => 'bundler',
        'source' => { 'repo' => 'my-group/my-project', 'directories' => ['/'] },
        'dependencies' => ['rails']
      )
    end

    context 'when filepath is in a subdirectory' do
      before do
        sbom_occurrence.update!(input_file_path: 'apps/backend/Gemfile')
      end

      it 'extracts the directory from the filepath' do
        expect(builder.build['source']['directories']).to eq(['/apps/backend'])
      end
    end

    context 'when filepath is blank' do
      before do
        sbom_occurrence.update!(input_file_path: nil)
      end

      it 'defaults to root directory' do
        expect(builder.build['source']['directories']).to eq(['/'])
      end
    end
  end

  describe '#to_json' do
    it 'returns valid JSON that matches the build hash' do
      parsed = ::Gitlab::Json.safe_parse(builder.to_json)

      expect(parsed).to eq(builder.build)
    end
  end
end
