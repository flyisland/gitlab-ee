# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class LigaaiMenu < ::Sidebars::Menu
        def link
          ligaai_integration.url
        end

        def title
          s_('JH|LigaaiIntegration|LigaAI')
        end

        def title_html_options
          {
            id: 'js-onboarding-settings-link'
          }
        end

        def sprite_icon
          'external-link'
        end

        def render?
          return false if ligaai_integration.blank?

          ligaai_integration.active?
        end

        private

        def ligaai_integration
          @ligaai_integration ||= context.project.ligaai_integration
        end
      end
    end
  end
end
