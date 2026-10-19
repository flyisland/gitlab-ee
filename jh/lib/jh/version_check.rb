# frozen_string_literal: true

module JH
  module VersionCheck
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    class_methods do
      extend ::Gitlab::Utils::Override

      override :host
      def host
        ENV['VERSION_DOT_HOST'] || ::ServicePing::SubmitService::JH_BASE_URL
      end

      def headers
        { REFERER: ::Gitlab.config.gitlab.url }
      end
    end

    override :calculate_reactive_cache
    def calculate_reactive_cache(*)
      response = ::Gitlab::HTTP.try_get(self.class.url, headers: self.class.headers)

      case response&.code
      when 200
        ::Gitlab::Json.parse(response.body)
      else
        { error: 'version check failed', status: response&.code }
      end
    rescue JSON::ParserError
      { error: 'parsing version check response failed', status: response&.code }
    end
  end
end
