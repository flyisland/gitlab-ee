# frozen_string_literal: true

module QA
  module Runtime
    module API
      class ThirdPartyRequest
        def self.masked_url(url)
          url.sub(/private_token=.*/, "private_token=[****]")
        end

        def initialize(api_client, path, **query_string)
          query_string[:private_token] ||= api_client.personal_access_token unless query_string[:access_token]
          request_path = request_path(path, **query_string)
          @session_address = Runtime::Address.new(api_client.address, request_path)
        end

        def mask_url
          QA::Runtime::API::ThirdPartyRequest.masked_url(url)
        end

        def url
          @session_address.address
        end

        def request_path(path, **query_string)
          full_path = ::File.join('/', path)

          if query_string.any?
            full_path << (path.include?('?') ? '&' : '?')
            full_path << query_string.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
          end

          full_path
        end
      end
    end
  end
end
