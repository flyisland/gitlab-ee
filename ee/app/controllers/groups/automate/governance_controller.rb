# frozen_string_literal: true

module Groups
  module Automate
    class GovernanceController < Groups::ApplicationController
      feature_category :compliance_management

      before_action :authorize_read_governance!
      before_action do
        push_frontend_feature_flag(:agent_artifacts_page, @group, type: :beta)
        push_frontend_feature_flag(:ai_governance_dashboard, @group, type: :beta)
        push_frontend_feature_flag(:ai_governance_mcp_server_activity, @group, type: :beta)
        push_frontend_feature_flag(:ai_governance_tool_calls, @group, type: :beta)
        push_frontend_feature_flag(:ai_governance_connected_agents_filter, @group, type: :beta)
        push_frontend_feature_flag(:ai_governance_dashboard_charts, @group, type: :beta)
        push_frontend_feature_flag(:ai_governance_skillguard_widget, @group, type: :wip)
        push_frontend_feature_flag(:ai_governance_sessions_api, @group, type: :beta)
      end

      def index
        @ai_audit_events_storage_enabled = group.ai_audit_events_storage_enabled
      end

      private

      def authorize_read_governance!
        render_404 unless render_governance_page?
      end

      def render_governance_page?
        # Top-level groups only: the tool-rules GraphQL surface
        # (Resolvers::Ai::ToolRulesResolver and the update mutations)
        # resolves root namespaces exclusively, so a subgroup page would
        # render and then fail every query.
        group.root? &&
          group.licensed_ai_features_available? &&
          can?(current_user, :read_ai_tool_rule, group)
      end
    end
  end
end
