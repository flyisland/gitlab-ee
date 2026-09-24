# frozen_string_literal: true

module JH
  module Sidebars
    module Projects
      module Menus
        module IssuesMenu
          extend ::Gitlab::Utils::Override

          override :configure_menu_items
          def configure_menu_items
            super

            add_item(ones_issue_list_menu_item)
            add_item(ones_external_link_menu_item)
            add_item(ligaai_issue_list_menu_item)
            add_item(ligaai_external_link_menu_item)

            true
          end

          def show_ones_menu_items?
            external_issue_tracker.is_a?(::Integrations::Ones) && \
              ones_active? && \
              context.project.licensed_feature_available?(:ones_issues_integration)
          end

          def show_ligaai_menu_items?
            external_issue_tracker.is_a?(::Integrations::Ligaai) && \
              ligaai_active? && \
              context.project.licensed_feature_available?(:ligaai_issues_integration)
          end

          private

          def ones_issue_list_menu_item
            return ::Sidebars::NilMenuItem.new(item_id: :ones_issue_list) unless show_ones_menu_items?

            ::Sidebars::MenuItem.new(
              title: s_('JH|OnesIntegration|ONES issues'),
              link: project_integrations_ones_issues_path(context.project),
              super_sidebar_parent: ::Sidebars::Projects::SuperSidebarMenus::PlanMenu,
              active_routes: { controller: 'projects/integrations/ones/issues' },
              item_id: :ones_issue_list
            )
          end

          def ones_external_link_menu_item
            return ::Sidebars::NilMenuItem.new(item_id: :ones_external_link) unless show_ones_menu_items?

            ::Sidebars::MenuItem.new(
              title: s_('JH|OnesIntegration|Open ONES'),
              link: external_issue_tracker.issue_tracker_path,
              super_sidebar_parent: ::Sidebars::Projects::SuperSidebarMenus::PlanMenu,
              active_routes: {},
              item_id: :ones_external_link,
              sprite_icon: context.is_super_sidebar ? nil : 'external-link',
              container_html_options: {
                target: '_blank',
                rel: 'noopener noreferrer'
              }
            )
          end

          def ligaai_active?
            !!ligaai_integration&.active?
          end

          def ones_active?
            !!ones_integration&.active?
          end

          def ligaai_issue_list_menu_item
            return ::Sidebars::NilMenuItem.new(item_id: :ligaai_issue_list) unless show_ligaai_menu_items?

            ::Sidebars::MenuItem.new(
              title: s_('JH|LigaaiIntegration|LigaAI issues'),
              link: project_integrations_ligaai_issues_path(context.project),
              super_sidebar_parent: ::Sidebars::Projects::SuperSidebarMenus::PlanMenu,
              active_routes: { controller: 'projects/integrations/ligaai/issues' },
              item_id: :ligaai_issue_list
            )
          end

          def ligaai_external_link_menu_item
            return ::Sidebars::NilMenuItem.new(item_id: :ligaai_external_link) unless show_ligaai_menu_items?

            ::Sidebars::MenuItem.new(
              title: s_('JH|LigaaiIntegration|Open LigaAI'),
              link: external_issue_tracker.issue_tracker_path,
              super_sidebar_parent: ::Sidebars::Projects::SuperSidebarMenus::PlanMenu,
              active_routes: {},
              item_id: :ligaai_external_link,
              sprite_icon: context.is_super_sidebar ? nil : 'external-link',
              container_html_options: {
                target: '_blank',
                rel: 'noopener noreferrer'
              }
            )
          end

          def ligaai_integration
            @ligaai_integration ||= context.project.ligaai_integration
          end

          def ones_integration
            @ones_integration ||= context.project.ones_integration
          end
        end
      end
    end
  end
end
