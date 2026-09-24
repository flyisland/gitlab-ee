# frozen_string_literal: true

module PerformanceAnalytics
  module MetricsHelper
    extend ActiveSupport::Concern

    MAX_RANGE_DAYS = ::Gitlab::Analytics::PerformanceAnalytics::RequestParams::MAX_RANGE_DAYS
    DEFAULT_DATE_RANGE = ::Gitlab::Analytics::PerformanceAnalytics::RequestParams::DEFAULT_DATE_RANGE

    INTERVAL_ALL = 'all'
    INTERVAL_MONTHLY = 'monthly'
    INTERVAL_DAILY = 'daily'
    AVAILABLE_INTERVALS = [INTERVAL_ALL, INTERVAL_MONTHLY, INTERVAL_DAILY].freeze
    DEFAULT_INTERVAL = INTERVAL_DAILY

    private

    def validate
      unless (end_date - start_date).days <= MAX_RANGE_DAYS
        return error(format(s_("JH|PerformanceAnalytics|Date range must be shorter than %{max_range} days."),
          { max_range: MAX_RANGE_DAYS.in_days.to_i }), :bad_request)
      end

      unless start_date <= end_date
        return error(s_('JH|PerformanceAnalytics|The start date must be earlier than the end date.'), :bad_request)
      end

      unless AVAILABLE_INTERVALS.include?(interval)
        return error(format(s_("JH|PerformanceAnalytics|The interval must be one of %{intervals}."),
          { intervals: AVAILABLE_INTERVALS.join(',') }), :bad_request)
      end

      unless available_metrics.include?(metric)
        return error(format(s_("JH|PerformanceAnalytics|The metric must be one of %{metrics}."),
          { metrics: available_metrics.join(',') }), :bad_request)
      end

      nil
    end

    def authorized?
      can?(current_user, :read_performance_analytics_metrics, container)
    end

    def authorization_error
      error(s_('JH|PerformanceAnalytics|You do not have permission to access performance analytics metrics.'),
        :unauthorized)
    end

    def start_date
      @from ||= to_date(params[:start_date] || DEFAULT_DATE_RANGE.ago)
    end

    def end_date
      @end_date ||= to_date(params[:end_date] || Time.current)
    end

    def interval
      @interval ||= params[:interval] || DEFAULT_INTERVAL
    end

    def metric
      @metric ||= params[:metric].to_s
    end

    def project_ids
      @project_ids ||= Array(params[:project_ids])
    end

    def user_ids
      @user_ids ||= Array(params[:user_ids])
    end

    def to_date(field)
      case field
      when Date
        field
      when Time
        field.to_date
      else
        Date.parse(field)
      end
    end

    def data_wrapper(query_result)
      case interval
      when INTERVAL_ALL
        { "value" => query_result }
      when INTERVAL_MONTHLY
        date_list = month_list(start_date, end_date).map { |date| date.strftime("%Y-%m") }
        date_list.map { |date| { "date" => date, "value" => query_result[date].to_i } }
      when INTERVAL_DAILY
        date_range = start_date..end_date
        date_list = date_range.step(1).map { |date| date.strftime("%F") }
        date_list.map { |date| { "date" => date, "value" => query_result[date].to_i } }
      end
    end

    def month_list(start_date, end_date)
      start_month = start_date.beginning_of_month
      end_month = end_date.beginning_of_month
      months = []
      while start_month < end_month
        months << start_month
        start_month = start_month.next_month
      end
      months << end_month
      months
    end
  end
end
