# frozen_string_literal: true

module Sbom
  module Ingestion
    module Tasks
      class IngestOccurrenceRefs < Base
        include Gitlab::Utils::StrongMemoize

        self.model = Sbom::OccurrenceRef

        private

        def after_ingest; end

        def insert_attributes
          occurrence_maps.map do |occurrence_map|
            {
              sbom_occurrence_id: occurrence_map.occurrence_id,
              security_project_tracked_context_id: tracked_context.id,
              pipeline_id: pipeline.id,
              project_id: project.id,
              commit_sha: commit_sha
            }
          end
        end

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
