# frozen_string_literal: true

module API
  module PerformanceAnalytics
    class Metrics < ::API::Base
      feature_category :not_owned
      urgency :low

      helpers do
        def feature_enabled?(container)
          ::Feature.enabled?(:performance_analytics, container) &&
            container.licensed_feature_available?(:performance_analytics)
        end
      end

      params do
        requires :id, type: String, desc: 'The ID of the project'
      end
      resource :projects, requirements: ::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        namespace ':id/performance_analytics/metrics' do
          desc 'Fetch the project-level performance analytics metrics'
          params do
            optional :start_date, type: Date, desc: 'Date range to start from.'
            optional :end_date, type: Date, desc: 'Date range to end at.'
            requires :metric, type: String, desc: 'The metric type.'
            optional :interval, type: String, desc: "The bucketing interval."
            optional :project_ids, type: Array[Integer], desc: "Filter by project IDs."
            optional :user_ids, type: Array[Integer], desc: "Filter by user IDs."
          end
          get do
            not_found! unless feature_enabled?(user_project)

            params = declared_params(include_missing: false)

            result = ::PerformanceAnalytics::ProjectMetricsService
              .new(project: user_project, current_user: current_user, params: params)
              .execute

            if result[:status] == :success
              present result[:data]
            else
              render_api_error!(result[:message], result[:http_status])
            end
          end
        end
      end

      params do
        requires :id, type: String, desc: 'The ID of the group'
      end
      resource :groups, requirements: ::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        namespace ':id/performance_analytics/metrics' do
          desc 'Fetch the group-level performance analytics metrics'
          params do
            optional :start_date, type: Date, desc: 'Date range to start from.'
            optional :end_date, type: Date, desc: 'Date range to end at.'
            requires :metric, type: String, desc: 'The metric type.'
            optional :interval, type: String, desc: "The bucketing interval."
            optional :user_ids, type: Array[Integer], desc: "Filter by user IDs."
          end
          get do
            not_found! unless feature_enabled?(user_group)

            params = declared_params(include_missing: false)

            result = ::PerformanceAnalytics::GroupMetricsService
              .new(group: user_group, current_user: current_user, params: params)
              .execute

            if result[:status] == :success
              present result[:data]
            else
              render_api_error!(result[:message], result[:http_status])
            end
          end
        end
      end
    end
  end
end
