# frozen_string_literal: true

module Types
  module Analytics
    module Orbit
      class IndexingProjectsType < BaseObject # rubocop:disable Graphql/AuthorizeTypes -- parent field authorizes
        graphql_name 'OrbitIndexingProjects'
        description 'Indexing progress of the projects in a group or project.'

        authorize_granular_token skip_reason: :parent_authorizes

        field :gaps, GraphQL::Types::Int, null: true,
          description: 'Number of projects that are not indexed.'
        field :indexed, GraphQL::Types::Int, null: true,
          description: 'Number of indexed projects.'
        field :total_known, GraphQL::Types::Int, null: true,
          description: 'Number of projects known to Orbit.'
      end
    end
  end
end
