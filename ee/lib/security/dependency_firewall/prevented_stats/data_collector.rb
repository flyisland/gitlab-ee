# frozen_string_literal: true

module Security
  module DependencyFirewall
    module PreventedStats
      # Projects read from PostgreSQL; groups return nil until they are served from ClickHouse.
      class DataCollector
        # Rule types behind the vulnerabilities card.
        VULNERABILITY_RULE_TYPES = %w[vulnerability risk_severity].freeze

        def initialize(container:, from:)
          @container = container
          @from = from
        end

        def counts
          return unless container.is_a?(Project)

          PostgresqlCollector.new(container: container, from: from).counts
        end

        private

        attr_reader :container, :from
      end
    end
  end
end
