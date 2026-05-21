# frozen_string_literal: true

# Security::ScanResultPolicies::GroupedFindingsEvaluator
#
# Returns `Security::Finding` UUIDs for a given pipeline with support for
# atomic scanner rule criteria. It handles scanner-specific vulnerability_attributes,
# severity_levels, vulnerabilities_allowed, and vulnerability_states by grouping scanners
# with the same attributes and executing batched queries.

module Security
  module ScanResultPolicies
    class GroupedFindingsEvaluator
      include GroupedEvaluatorConcern

      GroupResult = Struct.new(:uuids, :vulnerabilities_allowed, :vulnerability_states, keyword_init: true)

      def initialize(project, pipeline, params = {})
        @project = project
        @pipeline = pipeline
        @params = params
      end

      attr_reader :pipeline

      def grouped_results
        return unless scanner_configurations.present?

        execute_grouped_queries
      end

      private

      def execute_grouped_queries
        grouped_scanners = group_scanners_by_attributes

        return [] if grouped_scanners.empty?

        grouped_scanners.map do |attributes, scanner_types|
          finder_params = build_finder_params(scanner_types, attributes)
          uuids = FindingsFinder.new(project, pipeline, finder_params).execute.distinct_context_unaware_uuids

          GroupResult.new(
            uuids: uuids,
            vulnerabilities_allowed: attributes[:vulnerabilities_allowed],
            vulnerability_states: attributes[:vulnerability_states]
          )
        end
      end

      def group_key_mapping
        {
          severity_levels: :severity_levels,
          vulnerability_states: :vulnerability_states,
          vulnerabilities_allowed: :vulnerabilities_allowed
        }
      end

      def build_finder_params(scanner_types, group_attributes)
        vulnerability_attributes_from(group_attributes).merge(
          scanners: scanner_types,
          severity_levels: group_attributes[:severity_levels],
          dismissed: params[:dismissed],
          related_pipeline_ids: params[:related_pipeline_ids]
        ).compact
      end
    end
  end
end
