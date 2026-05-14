# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Authz::RedactionService, feature_category: :permissions do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:private_group) { create(:group, :private) }
  let_it_be(:private_group_with_access) { create(:group, :private) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:private_project) { create(:project, :private, group: private_group) }
  let_it_be(:private_project_with_access) { create(:project, :private, group: private_group_with_access) }

  before_all do
    private_group_with_access.add_developer(user)
  end

  before do
    stub_licensed_features(epics: true, security_dashboard: true)
  end

  describe '.supported_types' do
    it 'includes EE resource types' do
      expect(described_class.supported_types).to include(
        'epic', 'vulnerability', 'ci_pipeline', 'ci_stage', 'ci_build',
        'label', 'note', 'security_scan', 'security_finding',
        'vulnerability_scanner', 'vulnerability_occurrence', 'vulnerability_identifier'
      )
    end

    it 'includes CE resource types' do
      expect(described_class.supported_types).to include(
        'issue', 'merge_request', 'project', 'milestone', 'snippet', 'user', 'group'
      )
    end
  end

  describe '#execute' do
    subject(:result) { service.execute }

    let(:service) { described_class.new(user: user, resources_by_type: resources_by_type, source: 'test') }

    context 'with epics' do
      let_it_be(:public_epic) { create(:epic, group: group) }
      let_it_be(:private_epic) { create(:epic, group: private_group) }
      let_it_be(:accessible_epic) { create(:epic, group: private_group_with_access) }
      let_it_be(:confidential_epic) { create(:epic, :confidential, group: private_group_with_access) }

      context 'when user can access public epic' do
        let(:resources_by_type) { { 'epic' => { 'ids' => [public_epic.id], 'ability' => 'read_epic' } } }

        it 'allows access' do
          expect(result).to eq({ 'epic' => { public_epic.id => true } })
        end
      end

      context 'when user cannot access private epic' do
        let(:resources_by_type) { { 'epic' => { 'ids' => [private_epic.id], 'ability' => 'read_epic' } } }

        it 'denies access' do
          expect(result).to eq({ 'epic' => { private_epic.id => false } })
        end
      end

      context 'when user has group access' do
        let(:resources_by_type) { { 'epic' => { 'ids' => [accessible_epic.id], 'ability' => 'read_epic' } } }

        it 'allows access' do
          expect(result).to eq({ 'epic' => { accessible_epic.id => true } })
        end
      end

      context 'when user has group access to confidential epic' do
        let(:resources_by_type) { { 'epic' => { 'ids' => [confidential_epic.id], 'ability' => 'read_epic' } } }

        it 'allows access for group member' do
          expect(result).to eq({ 'epic' => { confidential_epic.id => true } })
        end
      end

      context 'when checking multiple epics at once' do
        let(:resources_by_type) do
          { 'epic' => { 'ids' => [public_epic.id, private_epic.id, accessible_epic.id],
                        'ability' => 'read_epic' } }
        end

        it 'returns correct authorization for each epic' do
          expect(result).to eq({
            'epic' => {
              public_epic.id => true,
              private_epic.id => false,
              accessible_epic.id => true
            }
          })
        end
      end

      context 'with non-existent epic' do
        let(:resources_by_type) { { 'epic' => { 'ids' => [non_existing_record_id], 'ability' => 'read_epic' } } }

        it 'denies access' do
          expect(result).to eq({ 'epic' => { non_existing_record_id => false } })
        end
      end
    end

    context 'with vulnerabilities' do
      let_it_be(:accessible_vulnerability) { create(:vulnerability, project: private_project_with_access) }
      let_it_be(:inaccessible_vulnerability) { create(:vulnerability, project: private_project) }

      context 'when user has project access' do
        let(:resources_by_type) do
          { 'vulnerability' => { 'ids' => [accessible_vulnerability.id], 'ability' => 'read_vulnerability' } }
        end

        it 'allows access' do
          expect(result).to eq({ 'vulnerability' => { accessible_vulnerability.id => true } })
        end
      end

      context 'when user does not have project access' do
        let(:resources_by_type) do
          { 'vulnerability' => { 'ids' => [inaccessible_vulnerability.id], 'ability' => 'read_vulnerability' } }
        end

        it 'denies access' do
          expect(result).to eq({ 'vulnerability' => { inaccessible_vulnerability.id => false } })
        end
      end

      context 'when checking multiple vulnerabilities at once' do
        let(:resources_by_type) do
          { 'vulnerability' => { 'ids' => [accessible_vulnerability.id, inaccessible_vulnerability.id],
                                 'ability' => 'read_vulnerability' } }
        end

        it 'returns correct authorization for each vulnerability' do
          expect(result).to eq({
            'vulnerability' => {
              accessible_vulnerability.id => true,
              inaccessible_vulnerability.id => false
            }
          })
        end
      end

      context 'with non-existent vulnerability' do
        let(:resources_by_type) do
          { 'vulnerability' => { 'ids' => [non_existing_record_id], 'ability' => 'read_vulnerability' } }
        end

        it 'denies access' do
          expect(result).to eq({ 'vulnerability' => { non_existing_record_id => false } })
        end
      end
    end

    context 'with ci_pipelines' do
      let_it_be(:accessible_pipeline) { create(:ci_pipeline, project: private_project_with_access) }
      let_it_be(:inaccessible_pipeline) { create(:ci_pipeline, project: private_project) }

      context 'when user has project access' do
        let(:resources_by_type) do
          { 'ci_pipeline' => { 'ids' => [accessible_pipeline.id], 'ability' => 'read_pipeline' } }
        end

        it 'allows access' do
          expect(result).to eq({ 'ci_pipeline' => { accessible_pipeline.id => true } })
        end
      end

      context 'when user does not have project access' do
        let(:resources_by_type) do
          { 'ci_pipeline' => { 'ids' => [inaccessible_pipeline.id], 'ability' => 'read_pipeline' } }
        end

        it 'denies access' do
          expect(result).to eq({ 'ci_pipeline' => { inaccessible_pipeline.id => false } })
        end
      end
    end

    context 'with ci_stages' do
      let_it_be(:accessible_pipeline) { create(:ci_pipeline, project: private_project_with_access) }
      let_it_be(:inaccessible_pipeline) { create(:ci_pipeline, project: private_project) }
      let_it_be(:accessible_stage) do
        create(:ci_stage, pipeline: accessible_pipeline, project: accessible_pipeline.project)
      end

      let_it_be(:inaccessible_stage) do
        create(:ci_stage, pipeline: inaccessible_pipeline, project: inaccessible_pipeline.project)
      end

      context 'when user has project access' do
        let(:resources_by_type) do
          { 'ci_stage' => { 'ids' => [accessible_stage.id], 'ability' => 'read_build' } }
        end

        it 'allows access via pipeline delegation' do
          expect(result).to eq({ 'ci_stage' => { accessible_stage.id => true } })
        end
      end

      context 'when user does not have project access' do
        let(:resources_by_type) do
          { 'ci_stage' => { 'ids' => [inaccessible_stage.id], 'ability' => 'read_build' } }
        end

        it 'denies access' do
          expect(result).to eq({ 'ci_stage' => { inaccessible_stage.id => false } })
        end
      end
    end

    context 'with labels' do
      let_it_be(:accessible_label) { create(:label, project: private_project_with_access) }
      let_it_be(:inaccessible_label) { create(:label, project: private_project) }

      context 'when user has project access' do
        let(:resources_by_type) do
          { 'label' => { 'ids' => [accessible_label.id], 'ability' => 'read_label' } }
        end

        it 'allows access' do
          expect(result).to eq({ 'label' => { accessible_label.id => true } })
        end
      end

      context 'when user does not have project access' do
        let(:resources_by_type) do
          { 'label' => { 'ids' => [inaccessible_label.id], 'ability' => 'read_label' } }
        end

        it 'denies access' do
          expect(result).to eq({ 'label' => { inaccessible_label.id => false } })
        end
      end
    end

    context 'with notes' do
      let_it_be(:accessible_issue) { create(:issue, project: private_project_with_access) }
      let_it_be(:inaccessible_issue) { create(:issue, project: private_project) }
      let_it_be(:accessible_note) { create(:note, noteable: accessible_issue, project: private_project_with_access) }
      let_it_be(:inaccessible_note) { create(:note, noteable: inaccessible_issue, project: private_project) }

      context 'when user has project access' do
        let(:resources_by_type) do
          { 'note' => { 'ids' => [accessible_note.id], 'ability' => 'read_note' } }
        end

        it 'allows access' do
          expect(result).to eq({ 'note' => { accessible_note.id => true } })
        end
      end

      context 'when user does not have project access' do
        let(:resources_by_type) do
          { 'note' => { 'ids' => [inaccessible_note.id], 'ability' => 'read_note' } }
        end

        it 'denies access' do
          expect(result).to eq({ 'note' => { inaccessible_note.id => false } })
        end
      end
    end

    context 'with mixed CE and EE resource types' do
      let_it_be(:public_issue) { create(:issue, project: project) }
      let_it_be(:public_epic) { create(:epic, group: group) }
      let_it_be(:accessible_vulnerability) { create(:vulnerability, project: private_project_with_access) }
      let_it_be(:private_mr) { create(:merge_request, source_project: private_project) }

      let(:resources_by_type) do
        {
          'issue' => { 'ids' => [public_issue.id], 'ability' => 'read_issue' },
          'epic' => { 'ids' => [public_epic.id], 'ability' => 'read_epic' },
          'vulnerability' => { 'ids' => [accessible_vulnerability.id], 'ability' => 'read_vulnerability' },
          'merge_request' => { 'ids' => [private_mr.id], 'ability' => 'read_merge_request' }
        }
      end

      it 'handles both CE and EE resource types correctly' do
        expect(result).to eq({
          'issue' => { public_issue.id => true },
          'epic' => { public_epic.id => true },
          'vulnerability' => { accessible_vulnerability.id => true },
          'merge_request' => { private_mr.id => false }
        })
      end
    end

    context 'with empty arrays for EE types' do
      let(:resources_by_type) do
        {
          'epic' => { 'ids' => [], 'ability' => 'read_epic' },
          'vulnerability' => { 'ids' => [], 'ability' => 'read_vulnerability' }
        }
      end

      it 'returns empty hashes for those types' do
        expect(result).to eq({ 'epic' => {}, 'vulnerability' => {} })
      end
    end

    context 'with missing ability (fail-closed)' do
      let_it_be(:public_epic) { create(:epic, group: group) }
      let_it_be(:private_epic) { create(:epic, group: private_group) }

      context 'when no ability is provided for EE type' do
        let(:resources_by_type) do
          { 'epic' => { 'ids' => [public_epic.id, private_epic.id] } }
        end

        it 'denies access for all resources when ability is not specified' do
          expect(result).to eq({
            'epic' => {
              public_epic.id => false,
              private_epic.id => false
            }
          })
        end
      end
    end
  end

  describe 'load_resources_for_type behavior' do
    context 'when EE resource type has no preload associations defined' do
      let_it_be(:public_epic) { create(:epic, group: group) }
      let(:resources_by_type) { { 'epic' => { 'ids' => [public_epic.id], 'ability' => 'read_epic' } } }
      let(:service) { described_class.new(user: user, resources_by_type: resources_by_type, source: 'test') }

      before do
        stub_const(
          "EE::Authz::RedactionService::EE_PRELOAD_ASSOCIATIONS",
          EE::Authz::RedactionService::EE_PRELOAD_ASSOCIATIONS.except(:epic)
        )
      end

      it 'does not raise an error when preloads are not defined' do
        expect { service.execute }.not_to raise_error
      end

      it 'still performs authorization correctly' do
        result = service.execute
        expect(result).to eq({ 'epic' => { public_epic.id => true } })
      end
    end

    context 'when group is handled as EE resource type' do
      let_it_be(:public_group) { create(:group, :public) }
      let(:service) { described_class.new(user: user, resources_by_type: resources_by_type, source: 'test') }

      context 'with valid group ids' do
        let(:resources_by_type) { { 'group' => { 'ids' => [public_group.id], 'ability' => 'read_group' } } }

        it 'loads and authorizes groups with EE-specific preloads' do
          result = service.execute
          expect(result).to eq({ 'group' => { public_group.id => true } })
        end
      end

      context 'with empty ids' do
        let(:resources_by_type) { { 'group' => { 'ids' => [], 'ability' => 'read_group' } } }

        it 'returns empty hash' do
          result = service.execute
          expect(result).to eq({ 'group' => {} })
        end
      end

      it 'includes group in EE_RESOURCE_CLASSES' do
        expect(EE::Authz::RedactionService::EE_RESOURCE_CLASSES[:group]).to eq(::Group)
      end

      it 'includes saml_provider in EE preload associations for group' do
        expect(EE::Authz::RedactionService::EE_PRELOAD_ASSOCIATIONS[:group]).to include(:saml_provider)
      end

      it 'includes system_note_metadata in EE preload associations for notes' do
        expect(EE::Authz::RedactionService::EE_PRELOAD_ASSOCIATIONS[:note]).to include(:system_note_metadata)
      end
    end
  end
end
