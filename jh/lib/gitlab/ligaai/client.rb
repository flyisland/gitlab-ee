# frozen_string_literal: true

module Gitlab
  module Ligaai
    class Client
      ACCESS_TOKEN_ENDPOINT = "https://ligai.cn/openapi/api/authorize/access-token"

      Error = Class.new(StandardError)
      ConfigError = Class.new(Error)

      attr_reader :integration

      def initialize(integration)
        raise ConfigError, 'Please check your integration configuration.' unless integration

        @integration = integration
      end

      def ping
        code, _data = begin
          fetch_project(ligaai_project_id)
        rescue StandardError
          {}
        end

        if requested_object_exists?(code)
          { success: true }
        else
          { success: false, message: 'Not Found' }
        end
      end

      def fetch_project(project_id)
        get("project/get", { projectId: project_id })
      end

      def fetch_issues(params = {})
        params = params.merge({ projectId: ligaai_project_id })
        post("issue/page", params)
      end

      def fetch_issue(issue_id)
        raise Error, 'invalid issue id' unless issue_id_pattern.match(issue_id)

        issue_code, issue = get("issue/get", { id: issue_id })
        if requested_object_exists?(issue_code)
          comment_code, comments = post('comment/page', {
            commentModule: "issue",
            linkId: issue_id,
            pageNumber: 1,
            pageSize: 20
          })

          if requested_object_exists?(comment_code) && comments['list'].present?
            issue['data']['comments'] = comments['list']
          end
        end

        [issue_code, issue]
      end

      private

      def issue_id_pattern
        /\A\d{8,10}\z/
      end

      def ligaai_project_id
        integration.project_key
      end

      def requested_object_exists?(code)
        code == '0'
      end

      def get(path, params = {})
        options = { headers: headers, query: params }
        response = Gitlab::HTTP.get(url(path), options)

        parsed_response(response)
      rescue JSON::ParserError
        raise Error, 'invalid response format'
      end

      def post(path, params = {})
        response = Gitlab::HTTP.perform_request(
          Net::HTTP::Post,
          url(path),
          {
            headers: headers,
            body: Gitlab::Json.generate(params)
          }
        )

        parsed_response(response)
      rescue JSON::ParserError
        raise Error, 'invalid response format'
      end

      def url(path)
        request_uri = if integration.api_url.present?
                        Gitlab::Utils.append_path(integration.api_url,
                          path)
                      else
                        Gitlab::Utils.append_path(integration.url, "/openapi/api/#{path}")
                      end

        URI.parse(request_uri)
      end

      def headers
        {
          'Content-Type': 'application/json',
          accessToken: access_token
        }
      end

      def parsed_response(response)
        body = Gitlab::Json.parse(response.body)
        code = body&.dig('code')
        data = body&.dig('data')

        return [code, data] if response.success? && requested_object_exists?(code)

        raise Gitlab::HTTP::Error,
          "GitLab:: LigaAI client error, url:#{response.request.uri}, code: #{code}, data: #{data}"
      end

      def access_token_cache_key
        "integration:ligaai_#{integration.user_key}_access_token"
      end

      def access_token
        token = Rails.cache.read(access_token_cache_key)
        return Gitlab::CryptoHelper.aes256_gcm_decrypt(token) if token.present?

        response = Gitlab::HTTP.perform_request(
          Net::HTTP::Post,
          ACCESS_TOKEN_ENDPOINT,
          {
            headers: { 'Content-Type' => 'application/json; charset=utf-8' },
            body: Gitlab::Json.generate({ clientId: integration.user_key, secretKey: integration.api_token })
          })

        _code, data = parsed_response(response)

        encrypted_token = Gitlab::CryptoHelper.aes256_gcm_encrypt(data['accessToken'])
        Rails.cache.write(access_token_cache_key, encrypted_token, expires_in: data['expireIn'])
        data['accessToken']
      rescue Gitlab::HTTP::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
        Gitlab::AppLogger.error(e.message.to_s)
        nil
      end
    end
  end
end
