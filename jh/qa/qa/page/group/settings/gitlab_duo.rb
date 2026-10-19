# frozen_string_literal: true

module QA
  module Page
    module Group
      module Settings
        class GitlabDuo < ::QA::Page::Base
          include Page::SubMenus::Common

          view 'ee/app/assets/javascripts/ai/settings/components/duo_configuration_settings_info_card.vue' do
            element 'duo-configuration-settings-action-buttons'
          end

          view 'ee/app/assets/javascripts/ai/settings/components/duo_flow_settings.vue' do
            element 'flows-subsection-header'
            element 'duo-flow-features-checkbox'
          end

          def go_to_gitlab_duo
            open_submenu('Settings', 'GitLab Duo')
          end

          def gitlab_duo_configuration_settings_displayed?
            has_element?('duo-configuration-settings-info-card')
          end

          def go_to_configuration
            within_element('duo-configuration-settings-action-buttons') do
              click_link('Change configuration')
            end

            wait_until(reload: false, message: 'Wait for GitLab Duo configuration page') do
              has_element?('duo-flow-features-checkbox', wait: 1, visible: false)
            end
          end

          def enable_foundational_flow(feature)
            scroll_to_element('flows-subsection-header')
            checkbox = find_field(feature, type: 'checkbox', visible: false)

            if checkbox.checked?
              QA::Runtime::Logger.info("Foundational flow already enabled: #{feature}")
              return
            end

            raise "Foundational flow is disabled: #{feature}" if checkbox.disabled?

            checkbox.check(allow_label_click: true)
            wait_until(reload: false, message: "Wait for #{feature} to be enabled") do
              find_field(feature, type: 'checkbox', visible: false).checked?
            end

            click_button('Save changes')
            wait_until(reload: false, message: 'Wait for GitLab Duo configuration to save') do
              has_content?('Group was successfully updated.', wait: 1)
            end
          end

          def purchase_credits_in_duo_menu
            click_element('duo-agent-platform-purchase-credits-link')
          end
        end
      end
    end
  end
end
