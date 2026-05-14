# frozen_string_literal: true

module Analytics
  module AggregationEngines
    class Contributions < Gitlab::Database::Aggregation::ClickHouse::Engine
      self.table_name = 'contributions_new'
      self.table_primary_key = %w[path created_at author_id id]
      self.table_columns = %w[path created_at author_id id target_type action updated_at version deleted]

      versioned_by :version, deleted_marker: :deleted

      metrics do
        count :users, :integer, -> { sql('author_id') }, distinct: true, description: 'Number of unique contributors'
        count description: 'Total number of contributions'
      end

      filters do
        exact_match :author_id, :string, description: 'Filter by one or many author Global IDs',
          formatter: gid_formatter
        range :created_at, :datetime, description: 'Filter by contribution timestamp'
      end
    end
  end
end
