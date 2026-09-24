# frozen_string_literal: true

module JH
  module Sidebars
    module Projects
      module Menus
        module AnalyticsMenu
          extend ::Gitlab::Utils::Override

          override :configure_menu_items
          def configure_menu_items
            return false unless can?(context.current_user, :read_analytics, context.project)

            result = super
            add_item(performance_analytics_menu_item) if result
            result
          end

          private

          def performance_analytics_menu_item
            return ::Sidebars::NilMenuItem.new(item_id: :performance_analytics) if performance_analytics_disabled?

            ::Sidebars::MenuItem.new(
              title: s_('JH|Performance Analytics'),
              link: project_analytics_performance_analytics_path(context.project),
              super_sidebar_parent: ::Sidebars::Projects::SuperSidebarMenus::AnalyzeMenu,
              active_routes: { path: 'performance_analytics#index' },
              item_id: :performance_analytics
            )
          end

          def performance_analytics_disabled?
            ::Feature.disabled?(:performance_analytics) ||
              !context.project.licensed_feature_available?(:performance_analytics)
          end
        end
      end
    end
  end
end
