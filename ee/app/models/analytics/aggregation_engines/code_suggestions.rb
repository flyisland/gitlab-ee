# frozen_string_literal: true

module Analytics
  module AggregationEngines
    class CodeSuggestions < Gitlab::Database::Aggregation::ClickHouse::Engine
      self.table_name = 'ai_code_suggestions'

      filters do
        exact_match :user_id, :string, description: 'Filter by one or many user Global IDs',
          formatter: gid_formatter
        exact_match :language, :string, description: 'Filter by suggestion language'
        exact_match :ide_name, :string, description: 'Filter by IDE name'
        range :timestamp, :datetime, description: 'Filter by suggestion timestamp'
      end

      dimensions do
        column :language, :string, description: 'Programming language'
        column :ide_name, :string, description: 'IDE name'
        column :user_id, :integer, description: 'User', association: true
        date_bucket :timestamp, :date, description: 'Suggestion timestamp', parameters: {
          granularity: { type: :string, in: %w[monthly] }
        }
      end

      metrics do
        count description: 'Total number of suggestions'
        count :users, :integer, -> { sql('user_id') }, distinct: true, description: 'Number of unique users'

        rate :acceptance, numerator_if: -> {
          sql('maxIfMerge(accepted_at) IS NOT NULL')
        }, denominator_if: -> {
          sql('minIfMerge(shown_at) IS NOT NULL')
        }, description: 'Acceptance rate (accepted / shown)'

        sum :suggestion_size, :integer, -> {
          sql('suggestion_size')
        }, description: 'Total suggestions volume'

        count :accepted, if: -> {
          sql('maxIfMerge(accepted_at) IS NOT NULL')
        }, description: 'Number of accepted suggestions'

        count :rejected, if: -> {
          sql('maxIfMerge(rejected_at) IS NOT NULL')
        }, description: 'Number of rejected suggestions'

        count :shown, if: -> {
          sql('minIfMerge(shown_at) IS NOT NULL')
        }, description: 'Number of shown suggestions'
      end

      def self.prepare_base_aggregation_scope(object)
        namespace = case object
                    when Project then object.project_namespace
                    else object
                    end

        builder = ClickHouse::Client::QueryBuilder.new(table_name)

        builder.where(builder.func('startsWith', [
          builder[:namespace_path], Arel::Nodes.build_quoted(namespace.traversal_path.to_s)
        ]))
      end
    end
  end
end
