# frozen_string_literal: true

module Resolvers
  module Ai
    module DuoWorkflows
      # Group-scoped session artifacts. Exposes `project_path` so a group can be
      # narrowed to a single descendant project.
      class GroupSessionArtifactsResolver < BaseSessionArtifactsResolver
        type ::Types::Ai::DuoWorkflows::SessionArtifactType.connection_type, null: true

        argument :project_path, GraphQL::Types::String,
          required: false,
          description: 'Filter by project full path.'

        private

        def unsupported_pg_args
          %i[workflow_definition project_path workflow_created_after workflow_created_before not]
        end

        def finder_params(args)
          {
            workflow_definition: args[:workflow_definition],
            project_path: args[:project_path],
            workflow_created_after: args[:workflow_created_after],
            workflow_created_before: args[:workflow_created_before],
            workflow_id: args[:workflow_id],
            not: args[:not]&.to_h
          }.compact
        end
      end
    end
  end
end
