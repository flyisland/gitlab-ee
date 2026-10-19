# frozen_string_literal: true

module Resolvers
  module Analytics
    module Orbit
      class ItemCountsResolver < BaseResolver
        include StatusResolvable

        extension ::Gitlab::Graphql::Limit::FieldCallCount, limit: 1

        type ::Types::Analytics::Orbit::ItemCountsType, null: true

        def resolve
          traversal_path = orbit_traversal_path
          return unless traversal_path

          request_orbit([traversal_path]) do |client, _paths_in_scope, request_context|
            check_orbit_rate_limit!(:orbit_item_counts)

            client.get_item_counts(user: current_user, traversal_path: traversal_path, request_context: request_context)
          end
        end
      end
    end
  end
end
