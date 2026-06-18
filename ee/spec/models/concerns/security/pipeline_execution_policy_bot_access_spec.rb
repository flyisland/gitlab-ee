# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::PipelineExecutionPolicyBotAccess, feature_category: :security_policy_management do
  let_it_be(:root_group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: root_group) }
  let_it_be(:bot_project) { create(:project, group: root_group) }
  let_it_be_with_reload(:project) { create(:project, group: subgroup) }
  let_it_be(:policy_project) { create(:project, :repository, group: root_group) }

  let(:setting) { project.project_setting }

  describe 'associations' do
    it 'belongs to pipeline_execution_policy_bot_access_group' do
      expect(setting)
        .to belong_to(:pipeline_execution_policy_bot_access_group).class_name('Group').optional
    end
  end

  describe 'validations' do
    context 'when pipeline_execution_policy_bot_access_enabled is true' do
      subject(:setting) { build(:project_setting, pipeline_execution_policy_bot_access_enabled: true) }

      it 'is valid with proper file patterns' do
        setting.pipeline_execution_policy_bot_access_file_patterns = ['*.yml', 'config/**/*.yaml']

        expect(setting).to be_valid
      end

      it 'is invalid with more than 20 file patterns' do
        setting.pipeline_execution_policy_bot_access_file_patterns = Array.new(21) { |i| "pattern#{i}.yml" }

        expect(setting).not_to be_valid
        expect(setting.errors[:pipeline_execution_policy_bot_access_file_patterns])
          .to include("cannot have more than #{described_class::MAX_FILE_PATTERNS} file patterns")
      end

      it 'is invalid with a pattern exceeding the maximum length' do
        long_pattern = "#{'a' * described_class::MAX_FILE_PATTERN_LENGTH}.yml"
        setting.pipeline_execution_policy_bot_access_file_patterns = [long_pattern]

        expect(setting).not_to be_valid
        expect(setting.errors[:pipeline_execution_policy_bot_access_file_patterns])
          .to include("individual patterns cannot exceed #{described_class::MAX_FILE_PATTERN_LENGTH} characters")
      end

      it 'is invalid with empty pattern in array' do
        setting.pipeline_execution_policy_bot_access_file_patterns = ['valid.yml', '']

        expect(setting).not_to be_valid
        expect(setting.errors[:pipeline_execution_policy_bot_access_file_patterns])
          .to include('cannot contain empty patterns')
      end

      it 'is invalid with path traversal in pattern' do
        setting.pipeline_execution_policy_bot_access_file_patterns = ['../secret.yml']

        expect(setting).not_to be_valid
        expect(setting.errors[:pipeline_execution_policy_bot_access_file_patterns])
          .to include('cannot contain path traversal')
      end

      it 'is invalid with pattern starting with /' do
        setting.pipeline_execution_policy_bot_access_file_patterns = ['/etc/passwd']

        expect(setting).not_to be_valid
        expect(setting.errors[:pipeline_execution_policy_bot_access_file_patterns])
          .to include('cannot start with /')
      end

      it 'normalizes patterns with leading ./ on save' do
        setting.pipeline_execution_policy_bot_access_file_patterns = ['./config/*.yml', './ci/**/*.yaml']
        setting.save!

        expect(setting.pipeline_execution_policy_bot_access_file_patterns).to match_array(['config/*.yml',
          'ci/**/*.yaml'])
      end
    end

    context 'when pipeline_execution_policy_bot_access_enabled is false' do
      subject(:setting) { build(:project_setting, pipeline_execution_policy_bot_access_enabled: false) }

      it 'skips file pattern validations' do
        setting.pipeline_execution_policy_bot_access_file_patterns = ['../traversal.yml', '', '/absolute.yml']

        expect(setting).to be_valid
      end
    end

    context 'when pipeline_execution_policy_bot_access_group_id is set' do
      let_it_be(:group) { create(:group) }

      it 'is valid with a valid group' do
        setting = build(:project_setting, pipeline_execution_policy_bot_access_group_id: group.id)

        expect(setting).to be_valid
      end

      it 'is invalid with an invalid group id' do
        setting = build(:project_setting, pipeline_execution_policy_bot_access_group_id: non_existing_record_id)

        expect(setting).not_to be_valid
        expect(setting.errors[:pipeline_execution_policy_bot_access_group]).to include('must be a valid group')
      end
    end

    context 'when pipeline_execution_policy_bot_access_group_id is nil' do
      it 'does not add validation errors' do
        setting = build(:project_setting, pipeline_execution_policy_bot_access_group_id: nil)

        setting.send(:validate_pipeline_execution_policy_bot_access_group)

        expect(setting.errors[:pipeline_execution_policy_bot_access_group]).to be_empty
      end
    end

    context 'when pipeline_execution_policy_bot_access_group is outside project hierarchy' do
      let_it_be(:external_group) { create(:group) }

      it 'is invalid because the group is not within the project hierarchy' do
        setting.pipeline_execution_policy_bot_access_group_id = external_group.id

        expect(setting).not_to be_valid
        expect(setting.errors[:pipeline_execution_policy_bot_access_group])
          .to include('must be within the project hierarchy')
      end
    end

    context 'when pipeline_execution_policy_bot_access_group is an ancestor of the project' do
      it 'is valid for root ancestor group' do
        setting.pipeline_execution_policy_bot_access_group_id = root_group.id

        expect(setting).to be_valid
      end

      it 'is valid for immediate parent group' do
        setting.pipeline_execution_policy_bot_access_group_id = subgroup.id

        expect(setting).to be_valid
      end
    end
  end

  describe '#allows_pipeline_execution_policy_bot_access?' do
    let_it_be(:policy_configuration, freeze: false) do
      create(:security_orchestration_policy_configuration,
        project: project,
        security_policy_management_project: policy_project)
    end

    before do
      setting.update!(
        pipeline_execution_policy_bot_access_enabled: true,
        pipeline_execution_policy_bot_access_file_patterns: ['*.yml', 'config/**/*.yaml'],
        pipeline_execution_policy_bot_access_group_id: nil
      )

      policy_configuration.update!(experiments: { 'pipeline_execution_policy_bot_access' => { 'enabled' => true } })
      allow(setting).to receive(:pipeline_execution_policy_bot_access_experiment_enabled?).and_return(true)
    end

    it 'returns false when bot access is disabled' do
      setting.update!(pipeline_execution_policy_bot_access_enabled: false)

      result = setting.allows_pipeline_execution_policy_bot_access?(
        file_path: 'test.yml',
        bot_project: bot_project
      )

      expect(result).to be false
    end

    it 'returns false when experiment is not enabled' do
      allow(setting).to receive(:pipeline_execution_policy_bot_access_experiment_enabled?).and_return(false)

      result = setting.allows_pipeline_execution_policy_bot_access?(
        file_path: 'test.yml',
        bot_project: bot_project
      )

      expect(result).to be false
    end

    context 'when experiment is enabled via inherited group policy' do
      it 'returns true when inherited group policy has experiment enabled' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: bot_project
        )

        expect(result).to be true
      end
    end

    context 'when bot project is in allowed group hierarchy' do
      it 'returns true for matching file pattern' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: bot_project
        )

        expect(result).to be true
      end

      it 'returns true for nested path matching glob pattern' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'config/ci/pipeline.yaml',
          bot_project: bot_project
        )

        expect(result).to be true
      end

      it 'returns false for non-matching file pattern' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.txt',
          bot_project: bot_project
        )

        expect(result).to be false
      end

      it 'returns false when glob does not match nested path' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: '.gitlab/ci/foo.yml',
          bot_project: bot_project
        )

        expect(result).to be false
      end

      it 'returns true for brace expansion patterns', :aggregate_failures do
        setting.update!(pipeline_execution_policy_bot_access_file_patterns: ['*.{rb,js}'])

        expect(setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'app.rb',
          bot_project: bot_project
        )).to be true

        expect(setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'app.js',
          bot_project: bot_project
        )).to be true

        expect(setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'app.py',
          bot_project: bot_project
        )).to be false
      end
    end

    context 'when bot project is in a subgroup of the allowed group' do
      let_it_be(:nested_subgroup) { create(:group, parent: root_group) }
      let_it_be(:nested_bot_project) { create(:project, group: nested_subgroup) }

      it 'returns true because the bot project namespace is a descendant of the allowed group' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: nested_bot_project
        )

        expect(result).to be true
      end
    end

    context 'when bot project is outside allowed group hierarchy' do
      it 'returns false' do
        other_group = create(:group)
        other_bot_project = create(:project, group: other_group)

        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: other_bot_project
        )

        expect(result).to be false
      end
    end

    context 'when file patterns are empty' do
      before do
        setting.update_column(:pipeline_execution_policy_bot_access_file_patterns, [])
      end

      it 'returns false' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: bot_project
        )

        expect(result).to be false
      end
    end

    context 'when bot project namespace is nil' do
      it 'returns false' do
        allow(bot_project).to receive(:namespace).and_return(nil)

        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: bot_project
        )

        expect(result).to be false
      end
    end

    context 'when explicit group is configured' do
      let_it_be(:allowed_subgroup) { create(:group, parent: subgroup) }
      let_it_be(:allowed_bot_project) { create(:project, group: allowed_subgroup) }

      before do
        setting.update!(pipeline_execution_policy_bot_access_group_id: allowed_subgroup.id)
      end

      it 'returns true for bot in explicitly allowed group' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: allowed_bot_project
        )

        expect(result).to be true
      end

      it 'returns false for bot in root group (not within allowed subgroup)' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: bot_project
        )

        expect(result).to be false
      end
    end

    context 'when project is in personal namespace' do
      let_it_be(:personal_project) { create(:project, :in_user_namespace) }
      let(:personal_setting) { personal_project.project_setting }

      before do
        personal_setting.update!(
          pipeline_execution_policy_bot_access_enabled: true,
          pipeline_execution_policy_bot_access_file_patterns: ['*.yml']
        )

        allow(personal_setting)
          .to receive(:pipeline_execution_policy_bot_access_experiment_enabled?).and_return(true)
      end

      it 'returns false because root ancestor is not a group' do
        result = personal_setting.allows_pipeline_execution_policy_bot_access?(
          file_path: 'test.yml',
          bot_project: bot_project
        )

        expect(result).to be false
      end
    end

    context 'with path traversal attempts' do
      it 'returns false for paths with ..' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: '../secret.yml',
          bot_project: bot_project
        )

        expect(result).to be false
      end

      it 'returns false for absolute paths' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: '/etc/passwd',
          bot_project: bot_project
        )

        expect(result).to be false
      end

      it 'normalizes paths with leading ./' do
        result = setting.allows_pipeline_execution_policy_bot_access?(
          file_path: './test.yml',
          bot_project: bot_project
        )

        expect(result).to be true
      end
    end

    it 'returns false when bot_project is nil' do
      result = setting.allows_pipeline_execution_policy_bot_access?(
        file_path: 'test.yml',
        bot_project: nil
      )

      expect(result).to be false
    end

    it 'returns false when file_path is blank' do
      result = setting.allows_pipeline_execution_policy_bot_access?(
        file_path: '',
        bot_project: bot_project
      )

      expect(result).to be false
    end
  end

  describe '#pipeline_execution_policy_bot_access_experiment_enabled?' do
    let_it_be(:policy_configuration, freeze: false) do
      create(:security_orchestration_policy_configuration,
        project: project,
        security_policy_management_project: policy_project)
    end

    it 'returns true when experiment is enabled in project policy' do
      policy_configuration.update!(experiments: { 'pipeline_execution_policy_bot_access' => { 'enabled' => true } })
      allow(project).to receive(:all_security_orchestration_policy_configurations).and_return([policy_configuration])

      expect(setting.pipeline_execution_policy_bot_access_experiment_enabled?).to be true
    end

    it 'returns false when experiment is not enabled' do
      policy_configuration.update!(experiments: {})
      allow(project).to receive(:all_security_orchestration_policy_configurations).and_return([policy_configuration])

      expect(setting.pipeline_execution_policy_bot_access_experiment_enabled?).to be false
    end

    it 'returns false when no policy configuration exists' do
      allow(project).to receive(:all_security_orchestration_policy_configurations).and_return([])

      expect(setting.pipeline_execution_policy_bot_access_experiment_enabled?).to be false
    end
  end
end
