# frozen_string_literal: true

module Groups
  module Settings
    class WorkItemsController < Groups::ApplicationController
      include WorkItems::SettingsPermissions

      layout 'group_settings'

      before_action :check_feature_availability_and_authorize

      feature_category :team_planning
      urgency :low

      before_action do
        push_frontend_feature_flag(:work_item_configurable_types, group.root_ancestor)
      end

      def show
        @hide_search_settings = true
        @is_root_group = group.root?
      end

      private

      def check_feature_availability_and_authorize
        render_404 unless can_access_work_item_settings?(group, current_user)
      end
    end
  end
end
