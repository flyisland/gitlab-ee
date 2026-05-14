# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyManagement::SecurityUpdate::Request, feature_category: :dependency_management do
  let_it_be(:project) { create(:project) }

  let_it_be(:vulnerability) do
    create(:vulnerability, :with_finding, :detected, project: project, report_type: :dependency_scanning)
  end

  let_it_be(:sbom_occurrence) do
    create(:sbom_occurrence,
      project: project,
      package_manager: 'bundler',
      input_file_path: 'Gemfile',
      component_name: 'rails'
    ).tap { |o| o.component_version.update!(version: '6.0.0') }
  end

  let(:source_ref) { 'feature-branch' }

  subject(:request) do
    described_class.new(
      sbom_occurrence: sbom_occurrence,
      vulnerability: vulnerability,
      source_ref: source_ref
    )
  end

  describe '#initialize' do
    context 'with an explicit source_ref' do
      it 'uses the provided source_ref' do
        expect(request.source_ref).to eq('feature-branch')
      end
    end

    context 'without a source_ref' do
      let(:source_ref) { nil }

      before do
        allow(project).to receive(:default_branch).and_return('main')
      end

      it 'defaults to the project default branch' do
        expect(request.source_ref).to eq('main')
      end
    end

    context 'when sbom_occurrence is nil' do
      let(:sbom_occurrence) { nil }

      it 'raises ArgumentError' do
        expect { request }.to raise_error(ArgumentError, 'sbom_occurrence is required')
      end
    end

    context 'when vulnerability is nil' do
      let(:vulnerability) { nil }

      it 'raises ArgumentError' do
        expect { request }.to raise_error(ArgumentError, 'vulnerability is required')
      end
    end

    context 'when sbom_occurrence and vulnerability do not belong to the same project' do
      before do
        allow(vulnerability).to receive(:project_id).and_return(sbom_occurrence.project_id + 1)
      end

      it 'raises ArgumentError' do
        expect { request }.to raise_error(ArgumentError,
          'vulnerability and sbom_occurrence must belong to the same project')
      end
    end
  end

  describe 'delegated attributes' do
    it 'exposes the expected sbom_occurrence attributes' do
      aggregate_failures do
        expect(request.sbom_occurrence).to eq(sbom_occurrence)
        expect(request.ecosystem).to eq('bundler')
        expect(request.filepath).to eq('Gemfile')
        expect(request.dependency).to eq('rails')
        expect(request.current_version).to eq('6.0.0')
      end
    end

    it 'exposes the vulnerability' do
      expect(request.vulnerability).to eq(vulnerability)
    end
  end
end
