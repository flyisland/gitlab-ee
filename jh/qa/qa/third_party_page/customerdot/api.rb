# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class API
        def initialize
          @url = Runtime::Env.customerdot_url
        end

        def sync_spend_credits
          token = Runtime::Env.customerdot_sync_spend_credits_token
          raise 'QA_CUSTOMERDOT_SYNC_SPEND_CREDITS_TOKEN is not configured' if token.empty?

          uri = URI.parse("#{@url}/internal/sync_spend_credits")
          uri.query = URI.encode_www_form(authentication_token: token)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')
          http.open_timeout = 10
          http.read_timeout = 120

          response = http.request(Net::HTTP::Get.new(uri.request_uri))
          unless response.is_a?(Net::HTTPSuccess)
            raise "CustomerDot credits spend sync failed with HTTP #{response.code}"
          end

          result = JSON.parse(response.body) # rubocop:disable Gitlab::Json not work
          message = result['message']
          required_fields = %w[time enrich_count consume_count]

          unless message.is_a?(Hash) && required_fields.all? { |field| message.key?(field) }
            raise 'CustomerDot credits spend sync returned an unexpected response'
          end

          QA::Runtime::Logger.info(
            "CustomerDot credits spend sync completed: " \
              "enriched #{message['enrich_count']}, consumed #{message['consume_count']}"
          )

          result
        rescue JSON::ParserError
          raise 'CustomerDot credits spend sync returned invalid JSON'
        rescue RuntimeError
          raise
        rescue StandardError => e
          raise "CustomerDot credits spend sync failed (#{e.class})"
        end
      end
    end
  end
end
