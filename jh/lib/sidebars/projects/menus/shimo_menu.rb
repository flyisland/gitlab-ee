# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class ShimoMenu < ::Sidebars::Menu
        override :link
        def link
          project_integrations_shimo_path(context.project)
        end

        override :title
        def title
          s_('JH|Shimo|Shimo')
        end

        override :image_path
        def image_path
          'logos/shimo.svg'
        end

        override :render?
        def render?
          project.shimo_integration&.render?
        end

        override :active_routes
        def active_routes
          { controller: :shimo }
        end

        private

        def project
          context.project
        end
      end
    end
  end
end
