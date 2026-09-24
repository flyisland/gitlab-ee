# frozen_string_literal: true

module JH
  module VersionDotHelpers
    # Let test cases of upstream pass normally
    # spec/services/service_ping/submit_service_ping_service_spec.rb
    ::ServicePing::SubmitService.send(:remove_const, :STAGING_BASE_URL) if defined?(::ServicePing::SubmitService)
    ::ServicePing::SubmitService::STAGING_BASE_URL = ::ServicePing::SubmitService::JH_BASE_URL
  end
end
