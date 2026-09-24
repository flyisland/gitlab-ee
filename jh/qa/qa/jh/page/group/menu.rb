# frozen_string_literal: true

module QA
  module JH
    module Page
      module Group
        module Menu
          def go_to_performance_analytics
            click_element('menu-section-button', menu_item: 'Analyze')
            click_element('nav-item-link', submenu_item: 'Performance Analytics')
          end
        end
      end
    end
  end
end
