# frozen_string_literal: true

module Groups
  module Settings
    module GitlabDuo
      class ConfigurationController < Groups::ApplicationController
        feature_category :ai_abstraction_layer

        include ::Nav::GitlabDuoSettingsPage

        before_action do
          push_frontend_feature_flag(:dap_group_customizable_permissions, @group, type: :wip)
          push_frontend_feature_flag(:dap_group_network_access_controls, @group, type: :beta)
        end

        def index
          redirect_to group_settings_gitlab_duo_path(group) unless render_configuration_page?
        end

        private

        def render_configuration_page?
          show_gitlab_duo_settings_menu_item?(group)
        end
      end
    end
  end
end
