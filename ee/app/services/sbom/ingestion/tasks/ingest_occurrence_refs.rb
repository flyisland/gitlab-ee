# frozen_string_literal: true

module Sbom
  module Ingestion
    module Tasks
      class IngestOccurrenceRefs < Base
        include Gitlab::Utils::StrongMemoize

        self.model = Sbom::OccurrenceRef
        self.unique_by = %i[sbom_occurrence_id security_project_tracked_context_id].freeze

        private

        def insert_attributes
          occurrence_maps.filter_map do |occurrence_map|
            # skip if related occurrence has not changed and
            # the occurrence_ref exists
            next if !occurrence_map.occurrence_changed &&
              existing_ref_occurrence_ids.include?(occurrence_map.occurrence_id)

            {
              sbom_occurrence_id: occurrence_map.occurrence_id,
              security_project_tracked_context_id: tracked_context.id,
              pipeline_id: pipeline.id,
              project_id: project.id,
              commit_sha: commit_sha
            }
          end
        end

        def existing_ref_occurrence_ids
          occurrence_ids = occurrence_maps.map(&:occurrence_id)
          return Set.new if occurrence_ids.empty?

          Sbom::OccurrenceRef
            .by_tracked_context(tracked_context.id)
            .by_occurrence(occurrence_ids)
            .pluck(:sbom_occurrence_id) # rubocop:disable Database/AvoidUsingPluckWithoutLimit,CodeReuse/ActiveRecord -- operating on a limited batch size
            .to_set
        end
        strong_memoize_attr :existing_ref_occurrence_ids

        def tracked_context
          response = ::Security::ProjectTrackedContexts::FindOrCreateService.from_pipeline(pipeline).execute

          if response.error?
            raise "Failed to find or create tracked context for project #{project.id}: #{response.errors.join(',')}"
          end

          response.payload[:tracked_context]
        end
        strong_memoize_attr :tracked_context

        def commit_sha
          pipeline.sha
        end
      end
    end
  end
end
