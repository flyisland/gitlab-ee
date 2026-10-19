# frozen_string_literal: true

module PerformanceAnalyticsApiAction
  extend ActiveSupport::Concern

  included do
    include PerformanceAnalyticsParams
    prepend_before_action :allow_sessionless_user, only: %i[summary leaderboard report report_summary]
    before_action :validate_params, only: %w[summary leaderboard report]
  end

  def summary
    respond_to do |format|
      format.json do
        render json: performance_analytics.summary_data
      end
    end
  end

  def leaderboard
    respond_to do |format|
      format.json do
        render json: performance_analytics.leaderboard_data
      end
    end
  end

  def report
    respond_to do |format|
      format.json do
        add_pagination_headers(performance_analytics.report_pagination)
        render json: performance_analytics.report_data
      end

      format.csv do
        send_data(performance_analytics.report_csv, type: 'text/csv; charset=utf-8')
      end
    end
  end

  def report_summary
    respond_to do |format|
      format.json do
        render json: performance_analytics.report_summary
      end
    end
  end

  private

  def performance_analytics
    raise NotImplementedError, "Expected #{name} to implement performance_analytics"
  end

  def add_pagination_headers(pagination)
    Gitlab::Pagination::OffsetHeaderBuilder.new(
      request_context: self,
      per_page: pagination[:per_page],
      page: pagination[:page],
      next_page: pagination[:next_page],
      prev_page: pagination[:prev_page],
      total: pagination[:total],
      total_pages: pagination[:total_pages],
      params: permitted_performance_analytics_params
    ).execute
  end

  def allow_sessionless_user
    authenticate_sessionless_user!(:api)
  end
end
