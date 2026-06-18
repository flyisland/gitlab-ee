# frozen_string_literal: true

module Groups
  module Settings
    module GitlabDuo
      class GovernanceController < Groups::ApplicationController
        feature_category :compliance_management

        include ::Nav::GitlabDuoSettingsPage

        before_action do
          push_frontend_feature_flag(:gitlab_duo_governance_settings, @group, type: :beta)
          push_frontend_feature_flag(:agent_artifacts_page, @group, type: :wip)
        end

        def index
          render_404 unless render_governance_page?
        end

        private

        def render_governance_page?
          show_gitlab_duo_settings_menu_item?(group) &&
            Feature.enabled?(:gitlab_duo_governance_settings, group)
        end
      end
    end
  end
end
