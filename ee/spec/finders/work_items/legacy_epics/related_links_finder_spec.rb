# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::LegacyEpics::RelatedLinksFinder, feature_category: :team_planning do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:subgroup) { create(:group, :public, parent: group) }
  let_it_be(:private_subgroup) { create(:group, :private, parent: group) }
  let_it_be(:other_group) { create(:group) }
  let_it_be(:epic1) { create(:epic, group: group) }
  let_it_be(:epic2) { create(:epic, group: group) }
  let_it_be(:epic3) { create(:epic, group: group) }
  let_it_be(:epic4) { create(:epic, group: group) }
  let_it_be(:epic5) { create(:epic, group: group) }
  let_it_be(:subgroup_epic) { create(:epic, group: subgroup) }
  let_it_be(:private_subgroup_epic) { create(:epic, group: private_subgroup) }
  let_it_be(:other_group_epic) { create(:epic, group: other_group) }
  let_it_be(:other_group_epic2) { create(:epic, group: other_group) }
  let_it_be(:related_epic_link1) { create(:related_epic_link, source: epic1, target: epic2) }
  let_it_be(:related_epic_link2) { create(:related_epic_link, source: epic3, target: epic4) }
  let_it_be(:other_related_epic) { create(:related_epic_link, source: epic4, target: epic5) }
  let_it_be(:subgroup_link) { create(:related_epic_link, source: subgroup_epic, target: epic1) }
  let_it_be(:private_subgroup_link) { create(:related_epic_link, source: private_subgroup_epic, target: epic2) }
  let_it_be(:other_group_link) { create(:related_epic_link, source: other_group_epic, target: epic3) }
  let_it_be(:both_other_group_link) { create(:related_epic_link, source: other_group_epic, target: other_group_epic2) }
  let_it_be(:non_epic_link) do
    create(:work_item_link, source: epic1.work_item, target: create(:work_item, :issue, namespace: group))
  end

  before_all do
    group.add_guest(user)
  end

  describe '#execute' do
    subject(:execute) { described_class.new(group, current_user: user).execute }

    let(:ids) { execute.map(&:id) }

    context 'when related_epic_links_from_work_items feature flag is enabled' do
      before do
        stub_feature_flags(related_epic_links_from_work_items: group)
      end

      it 'returns related work item links for epics in the group and sub-group hierarchy' do
        expect(execute).to include(
          related_epic_link1.related_work_item_link,
          related_epic_link2.related_work_item_link,
          other_related_epic.related_work_item_link
        )
      end

      it 'returns only valid related work item links within the hierarchy' do
        aggregate_failures do
          expect(execute.first).to be_a(::WorkItems::RelatedWorkItemLink)
          expect(ids).to include(subgroup_link.related_work_item_link.id)
          expect(ids).to include(other_group_link.related_work_item_link.id)
          expect(ids).not_to include(both_other_group_link.related_work_item_link.id)
          expect(ids).not_to include(non_epic_link.id)
        end
      end

      context 'when user is not a member of the group' do
        let_it_be(:non_member) { create(:user) }

        let(:ids_for_non_member) do
          described_class.new(group, current_user: non_member).execute.map(&:id)
        end

        it 'excludes links from private sub-groups the user cannot access' do
          expect(ids_for_non_member).not_to include(private_subgroup_link.related_work_item_link.id)
        end
      end

      context 'when user is not signed in' do
        let(:ids_for_guest) do
          described_class.new(group, current_user: nil).execute.map(&:id)
        end

        it 'excludes links where both source and target are in private sub-groups' do
          expect(ids_for_guest).not_to include(both_other_group_link.related_work_item_link.id)
        end
      end
    end

    context 'with date filters' do
      let(:filter_params) { {} }

      subject(:execute) { described_class.new(group, current_user: user, params: filter_params).execute }

      before do
        stub_feature_flags(related_epic_links_from_work_items: group)
      end

      context 'with updated_before' do
        let(:filter_params) { { updated_before: 1.day.ago } }

        it 'excludes links updated after the given date' do
          expect(ids).not_to include(related_epic_link1.related_work_item_link.id)
        end
      end

      context 'with updated_after' do
        let(:filter_params) { { updated_after: 1.day.from_now } }

        it 'excludes links updated before the given date' do
          expect(ids).to be_empty
        end
      end

      context 'with created_before' do
        let(:filter_params) { { created_before: 1.day.ago } }

        it 'excludes links created after the given date' do
          expect(ids).to be_empty
        end
      end

      context 'with created_after' do
        let(:filter_params) { { created_after: 1.day.ago } }

        it 'includes links created after the given date' do
          expect(ids).to include(
            related_epic_link1.related_work_item_link.id,
            related_epic_link2.related_work_item_link.id
          )
        end
      end
    end

    context 'when related_epic_links_from_work_items feature flag is disabled' do
      before do
        stub_licensed_features(epics: true, related_epics: true)
        stub_feature_flags(related_epic_links_from_work_items: false)
      end

      context 'with accessible legacy epics' do
        let(:legacy_epics) { EpicsFinder.new(user, group_id: group.id).execute }

        subject(:execute) do
          described_class
            .new(group, current_user: user, legacy_epics: legacy_epics).execute
        end

        it 'returns Epic::RelatedEpicLink instances for accessible epics' do
          expect(execute).to include(related_epic_link1, related_epic_link2, other_related_epic)
          expect(execute.first.class).to eq(Epic::RelatedEpicLink)
        end
      end

      context 'without legacy epics' do
        subject(:execute) do
          described_class.new(group, current_user: user).execute
        end

        it 'returns no results' do
          expect(execute).to be_empty
        end
      end
    end
  end
end
