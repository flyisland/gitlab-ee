# frozen_string_literal: true

module Gitlab
  module ContentValidation
    class Client
      def initialize
        @endpoint_enabled = Gitlab::CurrentSettings.current_application_settings.content_validation_endpoint_enabled
        @endpoint_url = Gitlab::CurrentSettings.current_application_settings.content_validation_endpoint_url
        @secret_key = Gitlab::CurrentSettings.current_application_settings.content_validation_api_key
      end

      def valid?(content)
        response = request('/api/content_validation/validate', { content: content })

        # Only return false if validation block and code is 406
        response.code != 406
      rescue Gitlab::HTTP::Error, StandardError => e
        Gitlab::AppLogger.info("#{self.class.name}: Error while connecting to #{@endpoint_url}: #{e}")
        true
      end

      def blob_validate(data)
        request("/api/content_validation/blob_validate", data)
      end

      def user_complaint(data)
        request("/api/content_validation/complaint", data)
      end

      def pre_check(data)
        request("/api/content_validation/pre_check", data)
      end

      private

      def allow_local_requests?
        Gitlab::CurrentSettings.allow_local_requests_from_system_hooks?
      end

      def header
        {
          'Authorization' => @secret_key,
          'Content-Type' => 'application/json'
        }
      end

      def request(path, body)
        return unless ::Gitlab.com? && ::Gitlab.jh? && @endpoint_enabled

        url = @endpoint_url + path
        Gitlab::HTTP.post(
          url,
          headers: header,
          body: ::Gitlab::Json.dump(body),
          use_read_total_timeout: true,
          timeout: 5,
          allow_local_requests: allow_local_requests?
        )
      end
    end
  end
end
