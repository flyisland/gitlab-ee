# frozen_string_literal: true

module Sbom
  class BulkEsOperationService
    def initialize(relation)
      @relation = relation
    end

    def execute
      return unless ::Search::Elastic::SbomOccurrenceRefIndexHelper.indexing_allowed?

      records = preload(relation)
      eligible_records = records.select(&:maintaining_elasticsearch?)

      ::Elastic::ProcessBookkeepingService.track!(*eligible_records)
    end

    private

    attr_reader :relation

    def preload(relation)
      occurrence_refs = relation.dup
      occurrence_refs.load

      ActiveRecord::Associations::Preloader.new(
        records: occurrence_refs,
        associations: [project: [:namespace]]
      ).call

      preloaded_namespaces = occurrence_refs.filter_map { |r| r.project&.namespace }
      ::Namespaces::Preloaders::NamespaceRootAncestorPreloader.new(preloaded_namespaces).execute

      occurrence_refs
    end
  end
end
