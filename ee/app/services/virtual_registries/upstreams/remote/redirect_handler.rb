# frozen_string_literal: true

module VirtualRegistries
  module Upstreams
    module Remote
      class RedirectHandler
        MAX_REDIRECTS = 5
        REDIRECT_STATUS_CODES = [301, 302, 303, 307, 308].freeze

        def initialize(headers:, timeout:, redirect_count: 0)
          @headers = headers
          @timeout = timeout
          @redirect_count = redirect_count
        end

        def redirect?(response)
          REDIRECT_STATUS_CODES.include?(response.code)
        end

        def build_follow_request(response)
          return if max_redirects_exceeded?

          url = redirect_url(response)
          return unless url

          request = PinnedRequestBuilder.build(url, headers: headers, timeout: timeout)
          return unless request

          next_handler = self.class.new(
            headers: headers,
            timeout: timeout,
            redirect_count: redirect_count + 1
          )

          request.on_complete do |follow_response|
            yield(follow_response, next_handler)
          end

          request
        end

        private

        attr_reader :headers, :timeout, :redirect_count

        def redirect_url(response)
          response.headers&.dig('Location')
        end

        def max_redirects_exceeded?
          redirect_count >= MAX_REDIRECTS
        end
      end
    end
  end
end
