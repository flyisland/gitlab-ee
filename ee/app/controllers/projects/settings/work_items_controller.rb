# frozen_string_literal: true

module Projects
  module Settings
    class WorkItemsController < Projects::ApplicationController
      layout 'project_settings'
      feature_category :team_planning

      before_action :authorize_work_item_settings!
      before_action :push_work_item_feature_flags

      private

      def authorize_work_item_settings!
        access_denied! unless ::Feature.enabled?(:work_item_configurable_types, @project.root_namespace)
      end

      def push_work_item_feature_flags
        push_frontend_feature_flag(:work_item_configurable_types, @project.root_namespace)
      end
    end
  end
end
