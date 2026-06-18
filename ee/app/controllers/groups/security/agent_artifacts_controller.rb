# frozen_string_literal: true

module Groups
  module Security
    class AgentArtifactsController < Groups::ApplicationController
      feature_category :compliance_management

      before_action :authorize_view_agent_artifacts!
      before_action :check_agent_artifacts_enabled!

      def index; end

      private

      def authorize_view_agent_artifacts!
        render_404 unless group.licensed_feature_available?(:group_level_compliance_dashboard) &&
          can?(current_user, :read_compliance_dashboard, group)
      end

      def check_agent_artifacts_enabled!
        render_404 unless Feature.enabled?(:agent_artifacts_page, group)
      end
    end
  end
end
