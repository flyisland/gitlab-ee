# frozen_string_literal: true

module API
  module Orbit
    module QueryResponseHelpers
      def render_orbit_query!(**query_args)
        unless ::Analytics::KnowledgeGraph::QueryRunner.enabled_for?(query_args.fetch(:user))
          status 200
          send_workhorse_headers!(*::Gitlab::Workhorse.send_orbit_query(**query_args))
          return body ''
        end

        response = ::Analytics::KnowledgeGraph::QueryRunner.new(
          ::Gitlab::Workhorse.orbit_query_params(**query_args), user: query_args.fetch(:user), env: env
        ).execute

        apply_etag_or_suppress_rack_etag!(nil)
        status response.status
        content_type response.content_type
        env['api.format'] = :binary
        body response.body
      end
    end
  end
end
