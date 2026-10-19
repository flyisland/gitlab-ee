# frozen_string_literal: true

module Gitlab
  module Ones
    class Client
      include QueryHelper

      Error = Class.new(StandardError)
      ConfigError = Class.new(Error)

      attr_reader :integration

      def initialize(integration)
        raise ConfigError, 'Please check your integration configuration.' unless integration

        @integration = integration
      end

      def ping
        response = begin
          graphql_query(project_query, key: "project-#{project_uuid}")
        rescue Error
          {}
        end

        active = response.dig('data', 'project', 'status').present?
        if active
          { success: true }
        else
          { success: false, message: 'Not Found' }
        end
      end

      def graphql_query(query, variables = {})
        url = URI.parse(Gitlab::Utils.append_path(api_url, "/items/graphql"))
        options = { headers: headers, body: Gitlab::Json.generate({ query: query, variables: variables }) }
        parse { ::Gitlab::HTTP.post(url, options) }
      end

      def message_query(task_uuid)
        url = URI.parse(Gitlab::Utils.append_path(api_url, "/task/#{task_uuid}/messages"))
        options = { headers: headers }
        parse { ::Gitlab::HTTP.get(url, options) }
      end

      def project_uuid
        integration.project_key
      end

      private

      def parse(&query)
        response = yield

        raise Gitlab::Ones::Client::Error, { request: query, response: response } unless response.success?

        Gitlab::Json.parse(response.body)
      rescue JSON::ParserError
        raise Gitlab::Ones::Client::Error, 'invalid response format'
      end

      def api_url
        host = integration.api_url.presence || integration.url
        Gitlab::Utils.append_path(host, "/project/api/project/team/#{team_uuid}")
      end

      def headers
        {
          'Content-Type': 'application/json',
          'Ones-User-Id': integration.user_key,
          'Ones-Auth-Token': integration.api_token
        }
      end

      def team_uuid
        integration.namespace
      end
    end
  end
end
