# frozen_string_literal: true

module QA
  module JH
    module Page
      module Project
        module Pages
          def accept_authorization
            find_element('button[data-testid="authorization-button"]').click
          end

          def go_to_access_page
            deployment_url = find_element('div[data-testid="deployment-url"]')
            deployment_url.find('a').click

            page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
          end
        end
      end
    end
  end
end
