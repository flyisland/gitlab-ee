# frozen_string_literal: true

module Packages
  module Pypi
    module Upstream
      # EE-only: fetches the upstream PyPI Simple (PEP 691 JSON) metadata for a package.
      class Client
        PEP_691_JSON_ACCEPT = 'application/vnd.pypi.simple.v1+json'
        TIMEOUT = 10

        UPSTREAM_FAILURE_ERRORS = [
          Net::OpenTimeout,
          Net::ReadTimeout,
          SocketError,
          ::Gitlab::HTTP_V2::BlockedUrlError,
          ::Gitlab::HTTP_V2::ReadTotalTimeout
        ].freeze

        def fetch_simple(package_name, base_url:)
          response = ::Gitlab::HTTP.get(
            Configuration.simple_url_for(package_name, base_url: base_url),
            headers: { 'Accept' => PEP_691_JSON_ACCEPT },
            allow_local_requests: false,
            timeout: TIMEOUT
          )

          handle_response(response)
        rescue *UPSTREAM_FAILURE_ERRORS => e
          ServiceResponse.error(message: e.message, reason: :upstream_failure)
        end

        private

        def handle_response(response)
          case response.code
          when 200
            parse(response.body)
          when 404
            ServiceResponse.error(message: 'Package not found on upstream PyPI', reason: :not_found)
          else
            ServiceResponse.error(message: "Upstream PyPI responded with #{response.code}", reason: :upstream_failure)
          end
        end

        def parse(body)
          parsed = ::Gitlab::Json.safe_parse(body)

          unless parsed.is_a?(Hash)
            return ServiceResponse.error(message: 'Upstream PyPI response is malformed', reason: :malformed)
          end

          files = parsed['files']

          unless files.is_a?(Array)
            return ServiceResponse.error(message: 'Upstream PyPI response is missing files',
              reason: :malformed)
          end

          ServiceResponse.success(payload: { files: files })
        rescue JSON::ParserError
          ServiceResponse.error(message: 'Upstream PyPI response could not be parsed', reason: :malformed)
        end
      end
    end
  end
end
