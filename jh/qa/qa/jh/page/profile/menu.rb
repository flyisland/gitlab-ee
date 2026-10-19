# frozen_string_literal: true

module QA
  module JH
    module Page
      module Profile
        module Menu
          # @!override :click_access_tokens
          def click_access_tokens
            if has_text?('Access tokens')
              click_element('nav-item-link', submenu_item: 'Access tokens')
            else
              click_element('nav-item-link', submenu_item: '访问令牌')
            end
          end

          # Add click_preferences
          def click_preferences
            has_text?('Preferences') ? click_link('Preferences') : click_link('偏好设置')
          end
        end
      end
    end
  end
end
