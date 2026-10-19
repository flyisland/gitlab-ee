# frozen_string_literal: true

module Resolvers
  module Analytics
    module Orbit
      class IndexingStatusResolver < BaseResolver
        include StatusResolvable

        MAX_TRAVERSAL_PATHS_PER_CALL = 100

        type ::Types::Analytics::Orbit::IndexingStatusType, null: true

        def resolve
          traversal_path = orbit_traversal_path
          return unless traversal_path

          BatchLoader::GraphQL.for(traversal_path).batch do |traversal_paths, loader|
            request_orbit(traversal_paths) do |client, paths_in_scope, request_context|
              paths_in_scope.each_slice(MAX_TRAVERSAL_PATHS_PER_CALL) do |paths|
                check_orbit_rate_limit!(:orbit_indexing_status)

                result = client.get_indexing_status(
                  user: current_user, traversal_paths: paths, request_context: request_context
                )
                result[:statuses].each { |status| loader.call(status[:traversal_path], status) }
              end
            end
          rescue ::Gitlab::Graphql::Errors::ResourceNotAvailable => e
            traversal_paths.each { |path| loader.call(path, e.class.new(e.message)) }
          end
        end
      end
    end
  end
end
