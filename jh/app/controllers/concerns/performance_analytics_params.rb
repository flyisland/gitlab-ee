# frozen_string_literal: true

module PerformanceAnalyticsParams
  extend ActiveSupport::Concern

  private

  def permitted_performance_analytics_params
    params.permit(*::Gitlab::Analytics::PerformanceAnalytics::RequestParams::STRONG_PARAMS_DEFINITION)
  end

  def all_performance_analytics_params
    permitted_performance_analytics_params.merge(current_user: current_user)
  end

  def request_params
    @request_params ||= ::Gitlab::Analytics::PerformanceAnalytics::RequestParams.new(all_performance_analytics_params)
  end

  def validate_params
    return unless request_params.invalid?

    render(
      json: { message: 'Invalid parameters', errors: request_params.errors },
      status: :unprocessable_entity
    )
  end
end
