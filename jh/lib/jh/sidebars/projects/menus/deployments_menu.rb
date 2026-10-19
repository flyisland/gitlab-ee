# frozen_string_literal: true

module JH
  module Sidebars
    module Projects
      module Menus
        module DeploymentsMenu
          extend ::Gitlab::Utils::Override

          override :pages_menu_item
          def pages_menu_item
            unless context.project.pages_available? && context.current_user&.can?(:update_pages, context.project)
              return ::Sidebars::NilMenuItem.new(item_id: :pages)
            end

            ::Sidebars::MenuItem.new(
              title: _('Pages'),
              link: project_pages_path(context.project),
              super_sidebar_parent: ::Sidebars::Projects::SuperSidebarMenus::DeployMenu,
              active_routes: { path: %w[pages#new pages#show] },
              item_id: :pages,
              description: _('Publish a static website from your repository.'),
              library_icon: 'documents'
            )
          end
        end
      end
    end
  end
end
