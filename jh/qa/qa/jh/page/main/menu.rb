# frozen_string_literal: true

module QA
  module JH
    module Page
      module Main
        module Menu
          # @override :go_to_menu_dropdown_option
          def go_to_menu_dropdown_option(option_name)
            within_top_menu do
              click_element(:navbar_dropdown)
              click_element(option_name)
            end
          end

          # @vierride :click_edit_profile_link
          def click_edit_profile_link
            retry_until(reload: false) do
              within_user_menu do
                click_element('edit-profile-link')
              end

              has_text?('用户设置') || has_text?('User Settings')
            end
          end
        end
      end
    end
  end
end
