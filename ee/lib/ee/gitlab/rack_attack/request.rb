# frozen_string_literal: true

module EE
  module Gitlab
    module RackAttack
      module Request
        extend ::Gitlab::Utils::Override

        VIRTUAL_REGISTRIES_API_PACKAGE_TYPES = ::VirtualRegistries::PACKAGE_TYPES.map(&:to_s).join('|')
        VIRTUAL_REGISTRIES_API_PACKAGES_ENDPOINTS_REGEX =
          %r{^/api/v\d+/virtual_registries/packages/(?:#{VIRTUAL_REGISTRIES_API_PACKAGE_TYPES})/\d+/}
        VIRTUAL_REGISTRIES_API_CONTAINER_ENDPOINTS_REGEX =
          %r{^/v2/virtual_registries/container/\d+/}
        GEO_PROXY_API_PATH_REGEX = %r{^/api/v\d+/geo/proxy\z}

        override :should_be_skipped?
        def should_be_skipped?
          super || verified_geo_request? || virtual_registries_api_endpoints? || geo_proxy_workhorse_request?
        end

        override :throttle_unauthenticated_git_http?
        def throttle_unauthenticated_git_http?
          return false if verified_geo_request?

          super
        end

        def geo?
          if env['HTTP_AUTHORIZATION']
            ::Gitlab::Geo::JwtRequestDecoder.geo_auth_attempt?(env['HTTP_AUTHORIZATION'])
          else
            false
          end
        end

        def verified_geo_request?
          return false unless geo?

          decoder = ::Gitlab::Geo::JwtRequestDecoder.new(env['HTTP_AUTHORIZATION'])
          decoder.decode.present?
        rescue StandardError
          false
        end

        def alerts_notify?
          web_request? && logical_path.include?('alerts/notify')
        end

        def virtual_registries_api_endpoints?
          matches?(VIRTUAL_REGISTRIES_API_PACKAGES_ENDPOINTS_REGEX) ||
            matches?(VIRTUAL_REGISTRIES_API_CONTAINER_ENDPOINTS_REGEX)
        end

        def geo_proxy_workhorse_request?
          return false unless matches?(GEO_PROXY_API_PATH_REGEX)

          ::Gitlab::Workhorse.verify_api_request!(::ActionDispatch::Http::Headers.new(self))
          true
        rescue JWT::DecodeError
          false
        end
      end
    end
  end
end
