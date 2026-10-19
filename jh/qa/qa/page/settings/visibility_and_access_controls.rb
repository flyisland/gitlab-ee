# frozen_string_literal: true

module QA
  module Page
    module Settings
      class VisibilityAndAccessControls < QA::Page::Base
        include Layout::Flash

        view 'app/views/admin/application_settings/general.html.haml' do
          element 'admin-visibility-access-settings'
        end

        view 'jh/app/views/admin/application_settings/_disable_download_button.html.haml' do
          element 'disable-source-code-download-checkbox'
        end

        def expand_visibility_and_access_controls
          click_element('admin-visibility-access-settings')
        end

        def check_disable_download_source_code
          check_element('disable-source-code-download-checkbox', true)
          within_element('admin-visibility-access-settings') do
            find_element('button[type="submit"]').click
          end
        end
      end
    end
  end
end
