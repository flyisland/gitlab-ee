# frozen_string_literal: true

module QA
  module JH
    module Page
      module Project
        module New
          # @override :set_visibility
          def set_visibility(visibility)
            super

            # self-managed does not support declarations
            return unless visibility.capitalize.to_s == 'Public' && has_declarations?

            check_element('agree-jihu-terms-checkbox', true, visible: true)
            check_element('agree-intellectual-property-checkbox', true, visible: true)
          end

          def has_declarations?
            has_element?('agree-jihu-terms-checkbox', wait: 1, visible: true) &&
              has_element?('agree-intellectual-property-checkbox', wait: 1, visible: true)
          end

          def click_gitee_link
            click_link 'Gitee'
          end

          def has_no_preview_for_this_file_type?
            wait_until(reload: true) do
              has_text?('No preview for this file type')
            end
          end

          def has_download_link?(text)
            has_css?("a[download='#{text}']")
          end
        end
      end
    end
  end
end
