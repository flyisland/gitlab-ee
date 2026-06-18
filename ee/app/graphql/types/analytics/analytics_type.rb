# frozen_string_literal: true

module Types
  module Analytics
    class AnalyticsType < BaseObject
      graphql_name 'Analytics'
      description "ClickHouse-based analytics endpoints. Data can be delayed by 10 minutes."

      extend ::Gitlab::Database::Aggregation::Graphql::Mounter

      mount_aggregation_engine ::Analytics::AggregationEngines::AgentPlatformSessions,
        field_name: :agent_platform_sessions,
        description: 'Aggregation engine for GitLab Duo Agent Platform sessions usage',
        authorize: :read_pro_ai_analytics do
        define_method(:aggregation_scope) do
          engine_class.prepare_base_aggregation_scope(object)
        end
      end

      mount_aggregation_engine ::Analytics::AggregationEngines::CodeSuggestions,
        field_name: :duo_code_suggestions,
        description: 'Aggregation engine for GitLab Duo Code Suggestions usage' do
        authorize :read_pro_ai_analytics

        define_method(:aggregation_scope) do
          engine_class.prepare_base_aggregation_scope(object)
        end
      end

      mount_aggregation_engine ::Analytics::AggregationEngines::AiUsageEvents,
        field_name: :duo_usage_events,
        description: 'Aggregation engine for GitLab Duo AI usage events' do
        authorize :read_pro_ai_analytics

        define_method(:aggregation_scope) do
          engine_class.prepare_base_aggregation_scope(object)
        end
      end

      mount_aggregation_engine ::Analytics::AggregationEngines::FinishedPipelines,
        field_name: :finished_pipelines,
        description: 'Aggregation engine for finished pipelines analytics',
        experiment: { milestone: '19.0' } do
        authorize :read_ci_cd_analytics

        define_method(:aggregation_scope) do
          engine_class.prepare_base_aggregation_scope(object)
        end
      end

      mount_aggregation_engine ::Analytics::AggregationEngines::Contributions,
        field_name: :contributions,
        description: 'Aggregation engine for contribution analytics',
        experiment: { milestone: '19.0' } do
        authorize :read_contribution_analytics

        define_method(:aggregation_scope) do
          engine_class.prepare_base_aggregation_scope(object)
        end
      end

      mount_aggregation_engine ::Analytics::AggregationEngines::Deployments,
        field_name: :deployments,
        description: 'Aggregation engine for deployment analytics',
        experiment: { milestone: '19.0' } do
        authorize :read_dora4_analytics

        define_method(:aggregation_scope) do
          engine_class.prepare_base_aggregation_scope(object)
        end
      end
    end
  end
end
