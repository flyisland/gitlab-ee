# frozen_string_literal: true

module QA
  module Page
    module Component
      class DuoAgentPlatform < QA::Page::Base
        view 'ee/app/assets/javascripts/ai/duo_agentic_chat/components/duo_agentic_chat_state_manager.vue' do
          element 'model-dropdown-container'
        end

        view 'ee/app/assets/javascripts/ai/shared/feature_settings/model_select_dropdown.vue' do
          element 'toggle-button'
          element 'dropdown-toggle-text'
        end

        view 'ee/app/assets/javascripts/ai/duo_agentic_chat/components/prompt_composer/prompt_composer.vue' do
          element 'chat-prompt-cancel-button'
          element 'chat-prompt-submit-button'
        end

        def wait_for_chat_response_complete(max_duration: 120)
          wait_until(
            max_duration: max_duration,
            reload: false,
            message: 'Wait for DAP Chat response to start'
          ) do
            has_element?('chat-prompt-cancel-button', wait: 1)
          end

          wait_until(
            max_duration: max_duration,
            reload: false,
            message: 'Wait for DAP Chat response to finish'
          ) do
            has_element?('chat-prompt-submit-button', wait: 1)
          end
        end

        def agentic_mode_toggle_visible?
          has_element?('toggle-label', text: /Agentic/i)
        end

        def agentic_mode_enabled?
          toggle_wrapper = find_element("toggle-wrapper", text: /Agentic/i)
          toggle_button = toggle_wrapper.find('button[role="switch"]')
          toggle_button['aria-checked'] == 'true'
        end

        def ensure_agentic_mode!
          return unless agentic_mode_toggle_visible? && !agentic_mode_enabled?

          within_element("toggle-wrapper", text: /Agentic/i) do
            click_element('button[role="switch"]')
          end
          wait_for_requests
        end

        def get_default_model
          within_element('model-dropdown-container') do
            find_element('dropdown-toggle-text').text
          end
        end

        def select_model_on_chat_panel
          target_model = ::QA::Runtime::Env.duo_agent_platform_model
          QA::Runtime::Logger.info("DAP Model from env: #{target_model}")

          return if target_model.nil? || target_model.empty?

          current_model = get_default_model
          QA::Runtime::Logger.info("Current DAP model: #{current_model}")

          if current_model == target_model
            QA::Runtime::Logger.info("DAP model already set to #{target_model}, skipping selection")
            return
          end

          within_element('model-dropdown-container') do
            click_element('toggle-button')
            wait_for_requests

            find('[data-testid^="listbox-item"]', text: target_model).click
          end
          wait_for_requests

          QA::Runtime::Logger.info("Selected DAP model: #{target_model}")
        end

        def expand_foundational_flow_settings
          click_element('button[aria-label="Expand GitLab Duo features"]')
        end

        def check_duo_feature_setting(feature)
          find('label', text: feature).click
          QA::Runtime::Logger.info("Checked #{feature} feature")
        end

        def save_duo_feature_setting
          section = find('#js-gitlab-duo-settings', match: :first)
          within(section) do
            click_element('button[type="submit"]')
          end
        end

        def has_group_updated_successfully?
          has_content?('Group was successfully updated.')
        end

        def enable_duo_foundational_flow_features(feature)
          expand_foundational_flow_settings
          scroll_to_element('duo-flow-features-checkbox')
          check_duo_feature_setting(feature)
          wait_for_requests
          save_duo_feature_setting
        end
      end
    end
  end
end
