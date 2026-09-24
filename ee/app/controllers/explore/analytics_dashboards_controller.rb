# frozen_string_literal: true

module Explore
  class AnalyticsDashboardsController < Explore::ApplicationController
    feature_category :custom_dashboards_foundation
    before_action :authenticate_user!
    before_action :check_feature_flag
    before_action do
      push_frontend_ability(
        ability: :create_custom_dashboard, resource: ::Current.organization, user: current_user
      )
    end

    def index; end

    private

    def check_feature_flag
      render_404 unless Feature.enabled?(:explore_analytics_dashboards, current_user)
    end
  end
end
