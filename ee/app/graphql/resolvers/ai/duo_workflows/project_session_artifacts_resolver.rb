# frozen_string_literal: true

module Resolvers
  module Ai
    module DuoWorkflows
      # Project-scoped session artifacts. The project is fixed by the parent
      # object, so this resolver intentionally omits the `project_path` filter
      # that the group resolver exposes.
      class ProjectSessionArtifactsResolver < BaseSessionArtifactsResolver
        type ::Types::Ai::DuoWorkflows::SessionArtifactType.connection_type, null: true

        private

        def unsupported_pg_args
          %i[workflow_definition workflow_created_after workflow_created_before not]
        end

        def finder_params(args)
          {
            workflow_definition: args[:workflow_definition],
            workflow_created_after: args[:workflow_created_after],
            workflow_created_before: args[:workflow_created_before],
            not: args[:not]&.to_h
          }.compact
        end
      end
    end
  end
end
