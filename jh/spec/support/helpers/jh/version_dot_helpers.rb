# frozen_string_literal: true

module JH
  module VersionDotHelpers
    # Let test cases of upstream pass normally
    # spec/services/service_ping/submit_service_spec.rb
    if ::Gitlab::TelemetryEndpoint.const_defined?(:STAGING_URL, false)
      ::Gitlab::TelemetryEndpoint.send(:remove_const, :STAGING_URL)
    end

    ::Gitlab::TelemetryEndpoint::STAGING_URL = ::ServicePing::SubmitService::JH_BASE_URL
  end
end
