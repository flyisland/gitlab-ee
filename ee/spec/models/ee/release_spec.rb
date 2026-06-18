# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Release do
  describe '.by_namespace_id' do
    let_it_be(:group, freeze: false) { create(:group) }
    let_it_be(:subgroup, freeze: false) { create(:group, parent: group) }
    let_it_be(:project_in_group, freeze: false) { create(:project, group: group) }
    let_it_be(:project_in_subgroup, freeze: false) { create(:project, group: subgroup) }
    let_it_be(:unrelated_project, freeze: false) { create(:project) }

    let_it_be(:release_in_group_project, freeze: false) { create(:release, project: project_in_group) }
    let_it_be(:release_in_subgroup_project_1, freeze: false) { create(:release, project: project_in_subgroup) }
    let_it_be(:release_in_subgroup_project_2, freeze: false) { create(:release, project: project_in_subgroup) }
    let_it_be(:release_in_unrelated_project, freeze: false) { create(:release, project: unrelated_project) }

    context 'when a single namespace id is passed' do
      let(:ns_id) { group.id }

      it 'returns releases associated to projects of the provided group' do
        expect(described_class.by_namespace_id(ns_id)).to match_array(
          [
            release_in_group_project
          ])
      end
    end

    context 'when an array of namespace ids is passed' do
      let(:ns_id) { group.self_and_descendants.select(:id) }

      it 'returns releases associated to projects of all provided groups' do
        expect(described_class.by_namespace_id(ns_id)).to match_array(
          [
            release_in_group_project,
            release_in_subgroup_project_1,
            release_in_subgroup_project_2
          ])
      end
    end
  end
end
