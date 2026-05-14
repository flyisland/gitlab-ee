# frozen_string_literal: true

module Projects
  module Security
    class AgentArtifactsController < Projects::ApplicationController
      feature_category :compliance_management

      before_action :authorize_view_agent_artifacts!
      before_action :check_agent_artifacts_enabled!

      def index; end

      private

      def authorize_view_agent_artifacts!
        render_404 unless project.licensed_feature_available?(:project_level_compliance_dashboard) &&
          can?(current_user, :read_compliance_dashboard, project)
      end

      def check_agent_artifacts_enabled!
        render_404 unless Feature.enabled?(:agent_artifacts_page, project.root_ancestor)
      end
    end
  end
end
