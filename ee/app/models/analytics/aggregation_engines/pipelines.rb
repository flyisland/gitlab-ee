# frozen_string_literal: true

module Analytics
  module AggregationEngines
    class Pipelines < Gitlab::Database::Aggregation::ClickHouse::Engine
      self.table_name = 'siphon_p_ci_pipelines'

      SOURCES = ::Enums::Ci::Pipeline.sources.freeze
      COMPLETED_STATUSES = ::Ci::HasStatus::COMPLETED_STATUSES.freeze

      dimensions do
        column :status, :string, description: 'Pipeline status'
        column :source, :string, description: 'Pipeline source',
          formatter: ->(value) { SOURCES.key(value)&.to_s }
        column :ref, :string, description: 'Pipeline ref'
        column :project_id, :integer, description: 'Project', association: {
          finder: ->(ids) { Project.where(id: ids).index_by(&:id) }
        }
        date_bucket :started_at, :datetime, description: 'Pipeline start time', parameters: {
          granularity: { type: :string, in: %w[daily weekly monthly] }
        }
        date_bucket :finished_at, :datetime, description: 'Pipeline finish time', parameters: {
          granularity: { type: :string, in: %w[daily weekly monthly] }
        }
      end

      metrics do
        count description: 'Total number of pipelines'

        quantile :duration, :float, ->(_params) {
          sql('duration')
        }, description: 'Pipeline duration quantile in seconds', parameters: {
          quantile: { type: :float, in: 0.0..1.0 }
        }

        rate :outcome,
          numerator_if: ->(params) {
            statuses = Array.wrap(params[:status]) & COMPLETED_STATUSES
            return sql('FALSE') if statuses.empty?

            sql("status IN (#{statuses.map { |s| "'#{s}'" }.join(', ')})")
          },
          denominator_if: ->(_params) { sql("status IN (#{COMPLETED_STATUSES.map { |s| "'#{s}'" }.join(', ')})") },
          description: 'Rate of pipelines with the given status among completed pipelines',
          parameters: {
            status: { type: :string, in: COMPLETED_STATUSES, array: true }
          }
      end

      filters do
        exact_match :status, :string, description: 'Filter by one or many pipeline statuses'
        exact_match :source, :string, description: 'Filter by one or many pipeline sources',
          formatter: ->(values) { Array.wrap(values).filter_map { |v| SOURCES[v.to_sym] } }
        exact_match :ref, :string, description: 'Filter by one or many pipeline refs'
        range :started_at, :datetime, description: 'Filter by pipeline start timestamp'
        range :finished_at, :datetime, description: 'Filter by pipeline finish timestamp'
      end

      def self.prepare_base_aggregation_scope(object)
        namespace = case object
                    when Project then object.project_namespace
                    else object
                    end

        builder = ClickHouse::Client::QueryBuilder.new(table_name)

        builder.where(
          builder.func('startsWith', [
            builder[:traversal_path],
            Arel::Nodes.build_quoted(namespace.traversal_path(with_organization: true).to_s)
          ])
        )
      end
    end
  end
end
