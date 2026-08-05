# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::ScanProfiles::Configuration, feature_category: :security_testing_configuration do
  describe '.defaults_for' do
    using RSpec::Parameterized::TableSyntax

    let(:registered_defaults) do
      Security::ScanProfiles::Configuration::Defaults::DependencyScanningPostProcessing::VALUES
    end

    where(:input, :expected) do
      :dependency_scanning_post_processing  | ref(:registered_defaults)
      'dependency_scanning_post_processing' | ref(:registered_defaults)
      nil                                   | {}
      :unknown_scan_type                    | {}
    end

    with_them do
      it { expect(described_class.defaults_for(input)).to eq(expected) }
    end
  end

  describe '.for' do
    let(:dependency_defaults) do
      described_class.defaults_for(:dependency_scanning_post_processing)
    end

    context 'when given nil' do
      it 'returns an empty hash' do
        expect(described_class.for(nil)).to eq({})
      end
    end

    context 'when the scan_type has no registered defaults' do
      let(:profile) do
        build(:security_scan_profile, :sast, configuration: { 'foo' => 'bar' })
      end

      it 'returns the persisted configuration symbolized' do
        expect(described_class.for(profile)).to eq(foo: 'bar')
      end
    end

    context 'when the scan_type has registered defaults' do
      using RSpec::Parameterized::TableSyntax

      where(:configuration, :override) do
        {}                                 | {}
        nil                                | {}
        ref(:nested_override)              | { auto_remediation: { severity_level: 'critical' } }
        { 'custom_key' => 'custom_value' } | { custom_key: 'custom_value' }
      end

      let(:nested_override) { { 'auto_remediation' => { 'severity_level' => 'critical' } } }

      with_them do
        let(:profile) do
          build(:security_scan_profile, :dependency_scanning_post_processing, configuration: configuration)
        end

        it { expect(described_class.for(profile)).to eq(dependency_defaults.deep_merge(override)) }
      end
    end

    context 'when the resolve_dependency_bump feature is enabled' do
      let_it_be(:group) { build_stubbed(:group) }
      let_it_be(:project) { build_stubbed(:project, group: group) }

      let(:profile) do
        build(:security_scan_profile, :dependency_scanning_post_processing,
          namespace: group, configuration: {})
      end

      before do
        allow(described_class).to receive(:resolve_dependency_bump_enabled?)
          .with(project).and_return(true)
      end

      it 'overrides auto_remediation.upgrade_policy to major' do
        config = described_class.for(profile, project: project)
        expect(config[:auto_remediation][:upgrade_policy]).to eq('major')
      end

      it 'preserves other default values', :aggregate_failures do
        config = described_class.for(profile, project: project)
        expect(config[:severity_level]).to eq(dependency_defaults[:severity_level])
        expect(config[:open_merge_requests_limit]).to eq(dependency_defaults[:open_merge_requests_limit])
      end

      context 'when the user has stored a different auto_remediation.upgrade_policy' do
        let(:profile) do
          build(:security_scan_profile, :dependency_scanning_post_processing,
            namespace: group,
            configuration: { 'auto_remediation' => { 'upgrade_policy' => 'patch' } })
        end

        it 'overrides the stored value to major' do
          config = described_class.for(profile, project: project)
          expect(config[:auto_remediation][:upgrade_policy]).to eq('major')
        end
      end
    end

    context 'when the resolve_dependency_bump feature is not enabled' do
      let_it_be(:project) { create(:project) }

      let(:profile) do
        build(:security_scan_profile, :dependency_scanning_post_processing, configuration: {})
      end

      before do
        allow(described_class).to receive(:resolve_dependency_bump_enabled?)
          .with(project).and_return(false)
      end

      it 'uses the default upgrade_policy' do
        config = described_class.for(profile, project: project)
        expect(config[:auto_remediation][:upgrade_policy]).to eq('minor')
      end
    end

    context 'when no project is provided' do
      let(:profile) do
        build(:security_scan_profile, :dependency_scanning_post_processing, configuration: {})
      end

      it 'uses the default upgrade_policy' do
        config = described_class.for(profile)
        expect(config[:auto_remediation][:upgrade_policy]).to eq('minor')
      end
    end

    context 'when the profile is a scanner type' do
      let_it_be(:project) { create(:project) }

      let(:profile) do
        build(:security_scan_profile, :sast,
          configuration: { 'auto_remediation' => { 'upgrade_policy' => 'patch' } })
      end

      it 'does not apply duo overrides' do
        config = described_class.for(profile, project: project)
        expect(config[:auto_remediation][:upgrade_policy]).to eq('patch')
      end
    end
  end

  describe '.resolve_dependency_bump_enabled?' do
    subject { described_class.send(:resolve_dependency_bump_enabled?, project) }

    context 'when project.duo_dependency_bump_breaking_changes_available? returns true' do
      let_it_be(:group) { build_stubbed(:group) }
      let_it_be(:project) { build_stubbed(:project, group: group) }

      before do
        allow(project).to receive(:duo_dependency_bump_breaking_changes_available?).and_return(true)
      end

      it { is_expected.to be true }
    end

    context 'when project.duo_dependency_bump_breaking_changes_available? returns false' do
      let_it_be(:group) { build_stubbed(:group) }
      let_it_be(:project) { build_stubbed(:project, group: group) }

      before do
        allow(project).to receive(:duo_dependency_bump_breaking_changes_available?).and_return(false)
      end

      it { is_expected.to be false }
    end

    context 'when the project is nil' do
      subject { described_class.send(:resolve_dependency_bump_enabled?, nil) }

      it { is_expected.to be false }
    end
  end
end
