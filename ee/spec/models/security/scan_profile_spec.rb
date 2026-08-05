# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::ScanProfile, feature_category: :security_testing_configuration do
  let_it_be(:root_level_group) { create(:group) }

  describe 'associations' do
    it { is_expected.to belong_to(:namespace).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_presence_of(:scan_type) }
    it { is_expected.to validate_inclusion_of(:gitlab_recommended).in_array([true, false]) }
    it { is_expected.to validate_length_of(:description).is_at_most(2047) }

    context 'when validating uniqueness of name scoped to namespace and type' do
      subject { create(:security_scan_profile, namespace: root_level_group, scan_type: :sast) }

      it { is_expected.to validate_uniqueness_of(:name).scoped_to([:namespace_id, :scan_type]) }
    end

    describe '#root_namespace_validation' do
      let_it_be(:subgroup) { create(:group, parent: root_level_group) }

      it 'is valid for root group namespace' do
        expect(build(:security_scan_profile, namespace: root_level_group)).to be_valid
      end

      it 'is invalid for non-root namespaces' do
        profile = build(:security_scan_profile, namespace: subgroup)

        expect(profile).not_to be_valid
        expect(profile.errors[:namespace]).to include('must be a root namespace.')
      end
    end

    describe 'configuration' do
      context 'for scanner profiles' do
        subject(:profile) { build(:security_scan_profile, namespace: root_level_group, scan_type: :sast) }

        it 'defaults to a valid empty hash' do
          expect(profile).to be_valid
        end

        it 'rejects any keys (strict-empty schema)', :aggregate_failures do
          profile.configuration = { 'anything' => 'value' }

          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'rejects non-object values', :aggregate_failures do
          profile.configuration = 'not-an-object'

          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'rejects nil values', :aggregate_failures do
          profile.configuration = nil

          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end
      end

      context 'for post-processing profiles' do
        let(:schema_path) do
          Rails.root.join(
            'ee/app/validators/json_schemas/security_profile_dependency_scanning_post_processing_configuration.json'
          )
        end

        let(:schema) { Gitlab::Json.safe_parse(File.read(schema_path)) }
        let(:auto_remediation_schema) { schema.dig('properties', 'auto_remediation', 'properties') }

        subject(:profile) do
          build(:security_scan_profile,
            :dependency_scanning_post_processing,
            namespace: root_level_group)
        end

        it 'accepts empty hash' do
          profile.configuration = {}
          expect(profile).to be_valid
        end

        it 'rejects nil values', :aggregate_failures do
          profile.configuration = nil
          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'accepts valid auto_remediation configuration', :aggregate_failures do
          profile.configuration = {
            'auto_remediation' => {
              'enabled' => true,
              'cooldown' => auto_remediation_schema.dig('cooldown', 'maximum'),
              'severity_level' => 'critical',
              'upgrade_policy' => 'minor',
              'open_merge_requests_limit' => auto_remediation_schema.dig('open_merge_requests_limit', 'maximum')
            }
          }
          expect(profile).to be_valid
        end

        it 'rejects unknown top-level keys', :aggregate_failures do
          profile.configuration = { 'unknown_key' => 'value' }
          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'rejects invalid severity_level values', :aggregate_failures do
          profile.configuration = {
            'auto_remediation' => { 'severity_level' => 'extreme' }
          }
          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'rejects invalid upgrade_policy values', :aggregate_failures do
          profile.configuration = {
            'auto_remediation' => { 'upgrade_policy' => 'platinum' }
          }
          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'rejects open_merge_requests_limit exceeding maximum', :aggregate_failures do
          max = auto_remediation_schema.dig('open_merge_requests_limit', 'maximum')
          profile.configuration = {
            'auto_remediation' => { 'open_merge_requests_limit' => max + 1 }
          }
          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'rejects cooldown exceeding maximum', :aggregate_failures do
          max = auto_remediation_schema.dig('cooldown', 'maximum')
          profile.configuration = {
            'auto_remediation' => { 'cooldown' => max + 1 }
          }
          expect(profile).not_to be_valid
          expect(profile.errors[:configuration]).to be_present
        end

        it 'adds a validation error when the schema file is missing', :aggregate_failures do
          allow(profile).to receive(:scan_type).and_return('unknown_post_processing')
          allow(profile).to receive_messages(post_processing?: true, scanner?: false)

          profile.valid?
          expect(profile.errors[:configuration]).to include("schema not found for scan type 'unknown_post_processing'")
        end
      end
    end
  end

  describe 'scopes' do
    let_it_be(:scan_profile_1) { create(:security_scan_profile, :sast, namespace: root_level_group, name: "profile 1") }
    let_it_be(:scan_profile_2) { create(:security_scan_profile, :sast, namespace: root_level_group, name: "profile 2") }

    let_it_be(:post_processing_profile) do
      create(:security_scan_profile,
        :dependency_scanning_post_processing,
        namespace: root_level_group,
        name: 'post processing')
    end

    describe '.with_trigger_type' do
      let_it_be(:git_push_trigger_1) do
        create(:security_scan_profile_trigger,
          namespace: root_level_group,
          scan_profile: scan_profile_1,
          trigger_type: :git_push_event)
      end

      it 'returns scan profiles with the specified trigger type' do
        result = described_class.with_trigger_type(:git_push_event)

        expect(result).to contain_exactly(scan_profile_1)
      end

      it 'returns empty relation when no profiles have the specified trigger type' do
        result = described_class.with_trigger_type(:default_branch_pipeline)

        expect(result).to be_empty
      end
    end

    describe '.by_gitlab_recommended' do
      let_it_be(:profile) { create(:security_scan_profile, namespace: root_level_group, scan_type: :secret_detection) }
      let_it_be(:gitlab_recommended_profile) do
        create(:security_scan_profile,
          namespace: root_level_group,
          scan_type: :secret_detection,
          gitlab_recommended: true,
          name: "gitlab_recommended_profile"
        )
      end

      it 'returns gitlab recommended profiles' do
        expect(described_class.by_gitlab_recommended).to match_array([gitlab_recommended_profile])
      end
    end

    describe '.scanner' do
      it 'returns only scanner profiles' do
        expect(described_class.scanner).to contain_exactly(scan_profile_1, scan_profile_2)
      end
    end

    describe '.post_processing' do
      it 'returns only post-processing profiles' do
        expect(described_class.post_processing).to contain_exactly(post_processing_profile)
      end
    end
  end

  describe 'class methods' do
    let_it_be(:scan_profile_1) { create(:security_scan_profile, namespace: root_level_group, name: "profile 1") }
    let_it_be(:scan_profile_2) { create(:security_scan_profile, :sast, namespace: root_level_group, name: "profile 2") }

    describe '.scan_profile_ids' do
      context 'when there are fewer records than MAX_PLUCK' do
        it 'returns all ids' do
          result = described_class.scan_profile_ids

          expect(result.count).to eq(2)
        end
      end

      context 'when there are more records than MAX_PLUCK' do
        before do
          stub_const("#{described_class}::MAX_PLUCK", 1)
        end

        it 'limits the number of ids returned to MAX_PLUCK' do
          result = described_class.scan_profile_ids

          expect(result.count).to eq(1)
        end
      end
    end

    describe '.scan_type_names_for_project' do
      let_it_be(:project) { create(:project, group: root_level_group) }
      let_it_be(:sast_profile) { create(:security_scan_profile, :sast, namespace: root_level_group, name: 'sast') }
      let_it_be(:ds_profile) do
        create(:security_scan_profile, namespace: root_level_group, scan_type: :dependency_scanning, name: 'ds')
      end

      context 'when project has profiles attached' do
        before_all do
          create(:security_scan_profile_project, project: project, scan_profile: sast_profile)
          create(:security_scan_profile_project, project: project, scan_profile: ds_profile)
        end

        it 'returns scan type names for the project' do
          result = described_class.scan_type_names_for_project(project)

          expect(result).to match_array(%w[sast dependency_scanning])
        end
      end

      context 'when project is nil' do
        it 'returns an empty array' do
          expect(described_class.scan_type_names_for_project(nil)).to be_empty
        end
      end

      context 'when project has no profiles' do
        let_it_be(:other_project) { create(:project, group: root_level_group) }

        it 'returns an empty array' do
          expect(described_class.scan_type_names_for_project(other_project)).to be_empty
        end
      end

      context 'when multiple profiles share the same scan type' do
        let_it_be(:another_sast_profile) { create(:security_scan_profile, :sast, namespace: root_level_group) }
        let_it_be(:project_with_dupes) { create(:project, group: root_level_group) }

        before_all do
          create(:security_scan_profile_project, project: project_with_dupes, scan_profile: sast_profile)
          create(:security_scan_profile_project, project: project_with_dupes, scan_profile: another_sast_profile)
        end

        it 'returns distinct scan type names' do
          result = described_class.scan_type_names_for_project(project_with_dupes)

          expect(result).to match_array(%w[sast])
        end
      end

      context 'when a post processing profile is attached' do
        let_it_be(:post_processing_profile) do
          create(:security_scan_profile,
            :dependency_scanning_post_processing,
            namespace: root_level_group,
            name: 'pp')
        end

        let_it_be(:project_with_pp) do
          create(:project, group: root_level_group, security_scan_profiles: [sast_profile, post_processing_profile])
        end

        it 'excludes post processing scan types from the result' do
          result = described_class.scan_type_names_for_project(project_with_pp)

          expect(result).to match_array(%w[sast])
        end
      end
    end
  end

  describe 'attribute stripping' do
    it 'strips whitespace from name' do
      scan_profile = build(:security_scan_profile, name: '  Test Profile  ')
      scan_profile.valid?
      expect(scan_profile.name).to eq('Test Profile')
    end

    it 'strips whitespace from description' do
      scan_profile = build(:security_scan_profile, description: '  Test Description  ')
      scan_profile.valid?
      expect(scan_profile.description).to eq('Test Description')
    end
  end

  describe 'nested attributes' do
    describe 'scan_profile_triggers' do
      let(:triggers_attributes) { [] }
      let(:base_attributes) do
        {
          namespace: root_level_group,
          scan_type: :secret_detection,
          name: 'Test Profile'
        }
      end

      let(:profile) do
        described_class.new(base_attributes.merge(scan_profile_triggers_attributes: triggers_attributes))
      end

      context 'with single trigger' do
        let(:triggers_attributes) { [{ trigger_type: :git_push_event }] }

        it 'sets namespace on scan_profile_trigger before validation' do
          profile.valid?
          expect(profile.scan_profile_triggers.first.namespace).to eq(root_level_group)
        end

        it 'persists scan_profile_trigger on save' do
          expect { profile.save! }.to change { Security::ScanProfileTrigger.count }.by(1)
          expect(profile.scan_profile_triggers.first).to have_attributes(
            trigger_type: 'git_push_event',
            namespace: root_level_group
          )
        end
      end

      context 'with multiple triggers' do
        let(:triggers_attributes) do
          [
            { trigger_type: :git_push_event },
            { trigger_type: :default_branch_pipeline }
          ]
        end

        it 'sets namespace on multiple triggers before validation' do
          profile.valid?
          expect(profile.scan_profile_triggers).to all(have_attributes(namespace: root_level_group))
        end

        it 'persists multiple triggers on save' do
          expect { profile.save! }.to change { Security::ScanProfileTrigger.count }.by(2)
          expect(profile.scan_profile_triggers).to all(have_attributes(namespace: root_level_group))
          expect(profile.scan_profile_triggers.pluck(:trigger_type))
            .to match_array(%w[git_push_event default_branch_pipeline])
        end
      end

      context 'when trigger already has a namespace' do
        let_it_be(:another_group) { create(:group) }
        let(:triggers_attributes) { [{ trigger_type: :git_push_event, namespace: another_group }] }

        it 'does not override existing namespace' do
          profile.valid?
          expect(profile.scan_profile_triggers.first.namespace).to eq(another_group)
        end
      end
    end
  end

  describe '#ci_template_name' do
    using RSpec::Parameterized::TableSyntax

    where(:scan_type, :expected_template_name) do
      nil                                   | 'default'
      :sast                                 | 'default'
      :secret_detection                     | 'default'
      :container_scanning                   | 'default'
      :dependency_scanning                  | 'v2'
      :dependency_scanning_post_processing  | 'default'
    end

    with_them do
      let(:scan_profile) { build(:security_scan_profile, scan_type: scan_type) }

      subject { scan_profile.ci_template_name }

      it { is_expected.to eq(expected_template_name) }
    end
  end

  describe '#post_processing?' do
    context 'when scan_type is a post processing type' do
      subject { build(:security_scan_profile, :dependency_scanning_post_processing) }

      it { is_expected.to be_post_processing }
    end

    context 'when scan_type is a scanner type' do
      subject { build(:security_scan_profile, :sast) }

      it { is_expected.not_to be_post_processing }
    end

    context 'when scan_type is nil' do
      subject { build(:security_scan_profile, scan_type: nil) }

      it { is_expected.not_to be_post_processing }
    end
  end

  describe '#scanner?' do
    context 'when scan_type is a post processing type' do
      subject { build(:security_scan_profile, :dependency_scanning_post_processing) }

      it { is_expected.not_to be_scanner }
    end

    context 'when scan_type is a scanner type' do
      subject { build(:security_scan_profile, :sast) }

      it { is_expected.to be_scanner }
    end

    context 'when scan_type is nil' do
      subject { build(:security_scan_profile, scan_type: nil) }

      it { is_expected.not_to be_scanner }
    end
  end

  describe '#effective_configuration' do
    it 'deep-merges the registered defaults with the persisted configuration', :aggregate_failures do
      profile = build(:security_scan_profile, :dependency_scanning_post_processing,
        configuration: { 'auto_remediation' => { 'severity_level' => 'critical' } })

      expect(profile.effective_configuration)
        .to eq(Security::ScanProfiles::Configuration.defaults_for(:dependency_scanning_post_processing)
          .deep_merge(auto_remediation: { severity_level: 'critical' }))

      # Independent of the deep_merge above: the persisted override is applied, un-overridden sibling defaults survive
      expect(profile.effective_configuration.dig(:auto_remediation, :severity_level)).to eq('critical')
      expect(profile.effective_configuration.dig(:auto_remediation, :cooldown)).to eq(7)
    end
  end

  context 'with loose foreign key on security_scan_profiles.namespace_id' do
    it_behaves_like 'cleanup by a loose foreign key' do
      let_it_be(:parent) { root_level_group }
      let_it_be(:model) { create(:security_scan_profile, namespace: parent) }
    end
  end
end
