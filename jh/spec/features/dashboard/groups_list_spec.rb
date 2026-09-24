# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dashboard Groups page', :js, feature_category: :groups_and_projects do
  let_it_be_with_reload(:user) { create(:user) }
  let_it_be_with_reload(:group) { create(:group, :private) }

  def click_group_caret(group)
    within_testid("groups-list-item-#{group.id}") do
      find_by_testid('nested-groups-project-list-item-toggle-button').click
    end
  end

  def visit_dashboard_groups_path
    sign_in(user)
    visit dashboard_groups_path
  end

  before do
    stub_feature_flags(your_work_groups_vue: false)
  end

  describe 'folder caret' do
    context 'when user has access to root group' do
      context 'when root group has no subgroup' do
        before_all do
          group.add_owner(user)
        end

        before do
          visit_dashboard_groups_path
        end

        it 'does not show folder caret' do
          within_testid("groups-list-item-#{group.id}") do
            expect(page).not_to have_selector("[data-testid='nested-groups-project-list-item-toggle-button']")
          end
        end
      end

      context 'when root group has subgroup' do
        before_all do
          group.add_owner(user)
          create(:group, :private, parent: group)
        end

        before do
          visit_dashboard_groups_path
        end

        it 'shows folder caret' do
          within_testid("groups-list-item-#{group.id}") do
            expect(page).to have_selector("[data-testid='nested-groups-project-list-item-toggle-button']")
          end
        end
      end
    end

    context 'when user has access to subgroup instead of rootgroup' do
      let_it_be_with_reload(:subgroup) { create(:group, :private, parent: group) }

      before_all do
        subgroup.add_owner(user)
      end

      before do
        visit_dashboard_groups_path
      end

      it 'shows folder caret' do
        within_testid("groups-list-item-#{subgroup.parent.id}") do
          expect(page).to have_selector("[data-testid='nested-groups-project-list-item-toggle-button']")
        end
      end

      context 'when rootgroup has multiple subgroups' do
        let!(:another_subgroup) { create(:group, :private, parent: group) }

        before do
          visit_dashboard_groups_path
        end

        it 'does not show other subgroups that user does not have access to' do
          click_group_caret(group)

          expect(page).to have_content(subgroup.name)
          expect(page).not_to have_content(another_subgroup.name)
        end
      end
    end

    context 'when user is an auditor and has access to subgroup instead of rootgroup' do
      let(:subgroup) { create(:group, :private, parent: group) }
      let(:user) { create(:user, :auditor) }

      before do
        stub_licensed_features(auditor_user: true)
        subgroup.add_owner(user)
        visit_dashboard_groups_path
      end

      it 'shows folder caret and rootgroup link is clickable' do
        within_testid("groups-list-item-#{subgroup.parent.id}") do
          expect(page).to have_selector("[data-testid='nested-groups-project-list-item-toggle-button']")
        end
      end
    end
  end
end
