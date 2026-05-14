# frozen_string_literal: true

module Sidebars # rubocop:disable Gitlab/BoundedContexts -- sidebar menu follows existing pattern
  module YourWork
    module Menus
      class OrbitMenu < ::Sidebars::Menu
        override :title
        def title
          s_('Orbit|Orbit')
        end

        override :sprite_icon
        def sprite_icon
          'rocket'
        end

        override :render?
        def render?
          context.current_user && Feature.enabled?(:knowledge_graph, context.current_user)
        end

        override :active_routes
        def active_routes
          { controller: 'dashboard/orbit' }
        end

        override :configure_menu_items
        def configure_menu_items
          add_item(data_explorer_item)
          add_item(schema_item)
          add_item(configuration_item)

          true
        end

        private

        def orbit_base_path
          dashboard_orbit_path
        end

        def data_explorer_item
          ::Sidebars::MenuItem.new(
            title: s_('Orbit|Data Explorer'),
            link: orbit_base_path,
            active_routes: { page: orbit_base_path },
            item_id: :orbit_data_explorer
          )
        end

        def schema_item
          ::Sidebars::MenuItem.new(
            title: s_('Orbit|Schema'),
            link: "#{orbit_base_path}/schema",
            active_routes: { page: "#{orbit_base_path}/schema" },
            item_id: :orbit_schema
          )
        end

        def configuration_item
          ::Sidebars::MenuItem.new(
            title: s_('Orbit|Configuration'),
            link: "#{orbit_base_path}/configuration",
            active_routes: { page: "#{orbit_base_path}/configuration" },
            item_id: :orbit_configuration
          )
        end
      end
    end
  end
end
