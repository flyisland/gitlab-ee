# frozen_string_literal: true

module Analytics
  module AggregationEngines
    class Deployments < Gitlab::Database::Aggregation::ClickHouse::Engine
      self.table_name = 'siphon_deployments'

      STATUSES = ::Deployment.statuses.freeze
      FINISHED_STATUS_INTS = STATUSES.values_at(:success, :failed, :canceled).join(', ').freeze

      transient(:is_finished_status) { sql("status IN (#{FINISHED_STATUS_INTS})") }
      transient(:duration_ms) do
        sql(
          'multiIf(isNotNull(finished_at),
          toUnixTimestamp64Milli(assumeNotNull(finished_at)) - toUnixTimestamp64Milli(created_at),
          NULL)'
        )
      end

      dimensions do
        column :status, :string, description: 'Deployment status',
          formatter: ->(value) { ::Deployment.statuses.key(value) }
        column :environment_id, :integer, description: 'Environment ID', association: true
        column :ref, :string, description: 'Deployment ref'
        date_bucket :created_at, :datetime, description: 'Deployment creation time', parameters: {
          granularity: { type: :string, in: %w[daily weekly monthly] }
        }
        date_bucket :finished_at, :datetime, description: 'Deployment finish time', parameters: {
          granularity: { type: :string, in: %w[daily weekly monthly] }
        }
      end

      metrics do
        count description: 'Total number of deployments'

        quantile :deployment_duration, :float, transient(:duration_ms),
          description: 'Deployment duration quantile in milliseconds',
          parameters: {
            quantile: { type: :float, in: 0.0..1.0 }
          }

        rate :success,
          numerator_if: ->(_params) { sql("status = #{STATUSES[:success]}") },
          denominator_if: transient(:is_finished_status),
          description: 'Deployment success rate (out of finished deployments)'

        rate :failure,
          numerator_if: ->(_params) { sql("status = #{STATUSES[:failed]}") },
          denominator_if: transient(:is_finished_status),
          description: 'Deployment failure rate (out of finished deployments)'

        rate :canceled,
          numerator_if: ->(_params) { sql("status = #{STATUSES[:canceled]}") },
          denominator_if: transient(:is_finished_status),
          description: 'Deployment canceled rate (out of finished deployments)'
      end

      filters do
        exact_match :status, :string, description: 'Filter by one or many deployment statuses',
          formatter: ->(values) { Array.wrap(values).filter_map { |v| ::Deployment.statuses[v] } }
        exact_match :environment_id, :string, description: 'Filter by one or many environment Global IDs',
          formatter: gid_formatter
        exact_match :ref, :string, description: 'Filter by one or many deployment refs'
        range :created_at, :datetime, description: 'Filter by deployment creation timestamp'
        range :finished_at, :datetime, description: 'Filter by deployment finish timestamp'
      end

      def self.prepare_base_aggregation_scope(object)
        namespace = case object
                    when Project then object.project_namespace
                    # Namespace
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
