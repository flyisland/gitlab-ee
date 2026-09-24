# frozen_string_literal: true

module QA
  module Page
    module Admin
      module Groups
        class Index < QA::Page::Base
          view 'app/assets/javascripts/admin/groups/index/components/app.vue' do
            element 'admin-groups-filtered-search-and-sort', required: true
          end

          view 'app/assets/javascripts/vue_shared/components/groups_list/group_list_item_actions.vue' do
            element 'groups-list-item-actions', required: true
          end

          def search_group_with_name(group_name)
            within_element('filtered-search-input') do
              find_element('filtered-search-term-input').set(group_name)
            end

            find_element('search-button').click
          end

          def edit_group
            click_element('groups-list-item-actions')
            click_element('disclosure-dropdown-item', text: 'Edit')
          end

          def select_plan(plan)
            select_element('plan-dropdown', plan)
          end

          def click_save_changes_button
            click_element('save-changes-button')
          end

          def edit_group_subscription(group_name, plan)
            Page::Main::Menu.perform(&:go_to_admin_area)
            Page::Admin::Menu.perform(&:go_to_groups_overview)

            search_group_with_name(group_name)
            edit_group
            select_plan(plan)
            click_save_changes_button
          end
        end
      end
    end
  end
end
