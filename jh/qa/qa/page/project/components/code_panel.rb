# frozen_string_literal: true

module QA
  module Page
    module Project
      module Components
        class CodePanel < Page::Base
          view 'app/assets/javascripts/vue_shared/components/code_dropdown/code_dropdown.vue' do
            element 'code-dropdown'
            element 'copy-ssh-url-button'
          end

          def open_code_panel
            click_element 'code-dropdown'
            has_element?('copy-ssh-url-button')
          end

          def has_download_source_code_is_disabled?
            has_text?('Download source code')
          end
        end
      end
    end
  end
end
