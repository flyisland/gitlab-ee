# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::ProjectSecurityScannersInformation do
  let(:project) { create(:project, :small_repo) }
  let(:pipeline) { create(:ci_pipeline, project: project, sha: project.commit.id, ref: project.default_branch) }

  before do
    create(:ci_build, :success, :sast, name: 'semgrep-sast', pipeline: pipeline)
    create(:ci_build, :success, :dast, pipeline: pipeline)
    create(:ci_build, :success, :license_scanning, pipeline: pipeline)
    create(:ci_build, :pending, :secret_detection, pipeline: pipeline)
    create(:ci_build, :sbom_dependency_scanning, :success, pipeline: pipeline)
  end

  describe '#available_scanners' do
    before do
      allow(project).to receive(:feature_available?).and_return(false)
      allow(project).to receive(:feature_available?).with(:sast).and_return(true)
      allow(project).to receive(:feature_available?).with(:dast).and_return(true)
    end

    it 'returns a list of all scanners available for the project' do
      expect(project.available_scanners).to match_array(%w[SAST DAST])
    end

    context 'when business_logic is available' do
      before do
        allow(project).to receive(:feature_available?).with(:business_logic).and_return(true)
      end

      it { expect(project.available_scanners).to include('BUSINESS_LOGIC') }

      context 'when bl_security_analyzer feature flag is disabled' do
        before do
          stub_feature_flags(bl_security_analyzer: false)
        end

        it { expect(project.available_scanners).not_to include('BUSINESS_LOGIC') }
      end

      context 'when bl_security_analyzer feature flag is enabled only for the root namespace' do
        before do
          stub_feature_flags(bl_security_analyzer: project.root_ancestor)
        end

        it { expect(project.available_scanners).to include('BUSINESS_LOGIC') }
      end
    end
  end

  describe '#enabled_scanners' do
    it 'returns a list of all scanners enabled for the project' do
      expect(project.enabled_scanners).to match_array(%w[SAST DAST SECRET_DETECTION])
    end

    context 'when bl_security_analyzer feature flag is disabled' do
      before do
        stub_feature_flags(bl_security_analyzer: false)
        allow(project).to receive(:scanner_enabled?).and_return(true)
      end

      it { expect(project.enabled_scanners).not_to include('BUSINESS_LOGIC') }
    end
  end

  describe '#scanners_run_by_last_pipeline' do
    subject(:scanners_run_in_last_pipeline) { project.scanners_run_in_last_pipeline }

    context 'when pipeline has no build reports' do
      let!(:new_pipeline) { create(:ci_pipeline, project: project, sha: project.commit.id, ref: project.default_branch) }

      it { is_expected.to be_empty }
    end

    it 'returns a list of all scanners which were run successfully in the latest pipeline' do
      expect(scanners_run_in_last_pipeline).to match_array(%w[DAST SAST])
    end

    it 'does not include non-security scanners' do
      expect(scanners_run_in_last_pipeline).not_to include(%w[LICENSE_SCANNING])
    end
  end
end
