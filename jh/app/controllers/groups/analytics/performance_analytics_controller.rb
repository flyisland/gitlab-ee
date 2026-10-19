# frozen_string_literal: true

module Groups
  module Analytics
    class PerformanceAnalyticsController < Groups::Analytics::ApplicationController
      include PerformanceAnalyticsApiAction

      layout 'group'
      before_action :performance_analytics_enabled!

      def index
        respond_to do |format|
          format.html
        end
      end

      private

      def performance_analytics_enabled!
        render_404 unless Feature.enabled?(:performance_analytics, @group) &&
          @group.licensed_feature_available?(:performance_analytics)
      end

      def performance_analytics
        @performance_analytics ||= ::Analytics::PerformanceAnalytics::GroupLevel.new(
          @group, options: request_params.to_options
        )
      end
    end
  end
end
