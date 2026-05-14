# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module SettingsMenu
          extend ::Gitlab::Utils::Override

          override :configure_menu_items
          def configure_menu_items
            return false unless super

            insert_item_after(:monitor, analytics_menu_item)
            insert_item_after(:ci_cd, work_item_settings_menu_item)

            if can?(context.current_user, :admin_project, context.project)
              insert_item_after(:general, service_accounts_menu_item)
            end

            true
          end

          def work_item_settings_menu_item
            unless ::Feature.enabled?(:work_item_configurable_types, context.project.root_namespace)
              return ::Sidebars::NilMenuItem.new(item_id: :work_items)
            end

            ::Sidebars::MenuItem.new(
              title: _('Work items'),
              link: project_settings_work_items_path(context.project),
              active_routes: { path: %w[projects/settings/work_items#show] },
              item_id: :work_items,
              container_html_options: { 'data-testid': 'project-work-items-settings' }
            )
          end

          def analytics_menu_item
            unless product_analytics_settings_allowed?(context.project)
              return ::Sidebars::NilMenuItem.new(item_id: :analytics)
            end

            ::Sidebars::MenuItem.new(
              title: _('Analytics'),
              link: project_settings_analytics_path(context.project),
              active_routes: { path: %w[projects/settings/analytics#show] },
              item_id: :analytics
            )
          end

          def service_accounts_menu_item
            return ::Sidebars::NilMenuItem.new(item_id: :service_accounts) unless service_accounts_available?

            ::Sidebars::MenuItem.new(
              title: _('Service accounts'),
              link: project_settings_service_accounts_path(context.project),
              active_routes: { path: %w[projects/settings/service_accounts#index] },
              item_id: :service_accounts
            )
          end

          private

          def service_accounts_available?
            can?(context.current_user, :read_service_account, context.project)
          end
        end
      end
    end
  end
end
