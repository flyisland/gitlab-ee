# frozen_string_literal: true

module Types
  module Analytics
    module Orbit
      class NamespaceType < BaseObject # rubocop:disable Graphql/AuthorizeTypes -- parent field authorizes
        graphql_name 'OrbitNamespace'
        description 'Orbit data of a group or project.'

        authorize_granular_token skip_reason: :parent_authorizes

        field :enabled_at, ::Types::TimeType,
          null: true,
          description: 'When Orbit was turned on for the top-level group. ' \
            'Null for subgroups, projects, and when Orbit is off.',
          experiment: { milestone: '19.5' }

        field :indexing_status,
          resolver: ::Resolvers::Analytics::Orbit::IndexingStatusResolver,
          description: 'Indexing status of the group or project.'

        field :item_counts,
          resolver: ::Resolvers::Analytics::Orbit::ItemCountsResolver,
          description: 'Number of indexed items in the group or project. ' \
            'This field can be resolved for only one group or project in any single request.'

        def enabled_at
          object.try(:knowledge_graph_enabled_namespace)&.created_at
        end
      end
    end
  end
end
