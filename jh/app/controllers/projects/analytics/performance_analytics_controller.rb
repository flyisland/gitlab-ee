# frozen_string_literal: true

module Projects
  module Analytics
    class PerformanceAnalyticsController < Projects::ApplicationController
      include PerformanceAnalyticsApiAction

      feature_category :team_planning
      before_action :performance_analytics_enabled!

      def index; end

      private

      def performance_analytics_enabled!
        render_404 unless Feature.enabled?(:performance_analytics, @project) &&
          @project.licensed_feature_available?(:performance_analytics)
      end

      def performance_analytics
        @performance_analytics ||= ::Analytics::PerformanceAnalytics::ProjectLevel.new(
          @project, options: request_params.to_options
        )
      end
    end
  end
end
