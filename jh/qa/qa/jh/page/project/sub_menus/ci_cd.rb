# frozen_string_literal: true

module QA
  module JH
    module Page
      module Project
        module SubMenus
          module CiCd
            # @override :go_to_pipeline_editor
            def go_to_pipeline_editor
              hover_ci_cd_pipelines do
                if has_element?(:sidebar_menu_item_link, text: 'Editor')
                  click_element(:sidebar_menu_item_link, menu_item: 'Editor')
                else
                  click_element(:sidebar_menu_item_link, menu_item: '编辑器')
                end
              end
            end

            private

            def hover_ci_cd_pipelines
              find_element(:sidebar_menu_link, menu_item: 'CI/CD').hover

              yield
            end
          end
        end
      end
    end
  end
end
