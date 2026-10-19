# frozen_string_literal: true

module JH
  module Gitlab
    module TelemetryEndpoint
      extend ::Gitlab::Utils::Override

      module ::Gitlab
        module TelemetryEndpoint
          remove_const(:PRODUCTION_URL)
          PRODUCTION_URL = ::ServicePing::SubmitService::JH_BASE_URL

          remove_const(:STAGING_URL)
          STAGING_URL = PRODUCTION_URL
        end
      end

      override :default_url
      def default_url
        ENV['VERSION_DOT_HOST'].presence || super
      end
    end
  end
end
