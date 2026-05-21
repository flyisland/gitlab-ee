# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::SecurityPolicyEligibleProjectsFinder, feature_category: :security_policy_management do
  describe '#execute' do
    let_it_be(:user) { create(:user) }

    # Hierarchy:
    #   top_group/
    #     subgroup_a/          <- linked to SPP
    #       project_a1         (descendant - should be visible)
    #       child_group/
    #         project_a2       (nested descendant - should be visible)
    #     subgroup_b/          <- sibling of linked group
    #       project_b1         (sibling - should be visible)
    #     project_top          (parent level - should be visible)
    let_it_be(:top_group) { create(:group) }
    let_it_be(:subgroup_a) { create(:group, parent: top_group) }
    let_it_be(:child_group) { create(:group, parent: subgroup_a) }
    let_it_be(:subgroup_b) { create(:group, parent: top_group) }

    let_it_be(:project_a1) { create(:project, group: subgroup_a) }
    let_it_be(:project_a2) { create(:project, group: child_group) }
    let_it_be(:project_b1) { create(:project, group: subgroup_b) }
    let_it_be(:project_top) { create(:project, group: top_group) }

    # A separate root group with its own project
    let_it_be(:other_group) { create(:group) }
    let_it_be(:project_other) { create(:project, group: other_group) }

    let_it_be(:security_policy_project) do
      create(:project, security_policy_project_linked_groups: [subgroup_a])
    end

    let(:params) { {} }
    let(:spp) { security_policy_project }

    subject(:result) { described_class.new(user, spp, params).execute }

    before_all do
      top_group.add_developer(user)
    end

    before do
      stub_licensed_features(security_orchestration_policies: true)
    end

    it 'returns projects from the linked group' do
      expect(result).to include(project_a1, project_a2)
    end

    it 'returns projects from sibling groups' do
      expect(result).to include(project_b1)
    end

    it 'returns projects from parent groups' do
      expect(result).to include(project_top)
    end

    it 'does not return projects from unrelated groups' do
      expect(result).not_to include(project_other)
    end

    context 'when multiple linked groups share the same root ancestor' do
      before do
        create(:security_orchestration_policy_configuration, :namespace,
          namespace: subgroup_b,
          security_policy_management_project: security_policy_project)
      end

      it 'deduplicates and returns all projects under the shared root' do
        expect(result).to contain_exactly(project_a1, project_a2, project_b1, project_top)
      end
    end

    context 'when linked groups span multiple root ancestors' do
      before_all do
        other_group.add_developer(user)
      end

      before do
        create(:security_orchestration_policy_configuration, :namespace,
          namespace: other_group,
          security_policy_management_project: security_policy_project)
      end

      it 'returns projects from all root namespaces' do
        expect(result).to include(project_a1, project_a2, project_b1, project_top, project_other)
      end
    end

    context 'when SPP has no linked groups' do
      let_it_be(:empty_spp) { create(:project) }
      let(:spp) { empty_spp }

      it 'returns no projects' do
        expect(result).to eq(Project.none)
      end
    end

    context 'when security_policy_project is nil' do
      let(:spp) { nil }

      it 'returns no projects' do
        expect(result).to eq(Project.none)
      end
    end

    context 'when license is not available' do
      before do
        stub_licensed_features(security_orchestration_policies: false)
      end

      it 'returns no projects' do
        expect(result).to eq(Project.none)
      end
    end

    context 'when user does not have access to some projects' do
      let_it_be(:restricted_user) { create(:user) }
      let_it_be(:private_project) { create(:project, :private, group: subgroup_b) }

      subject(:result) { described_class.new(restricted_user, spp, params).execute }

      it 'excludes projects not visible to the user' do
        expect(result).not_to include(private_project)
      end
    end

    context 'with archived projects' do
      let_it_be(:archived_project) { create(:project, :archived, group: subgroup_a) }

      it 'excludes archived projects' do
        expect(result).not_to include(archived_project)
      end
    end

    context 'with search parameter' do
      let(:params) { { search: project_b1.name } }

      it 'filters results by search term' do
        expect(result).to include(project_b1)
        expect(result).not_to include(project_a1)
      end
    end

    context 'with empty search parameter' do
      let(:params) { { search: '' } }

      it 'returns all visible projects' do
        expect(result).to include(project_a1, project_a2, project_b1, project_top)
      end
    end
  end
end
