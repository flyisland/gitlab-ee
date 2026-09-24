# frozen_string_literal: true

module JH
  module ContentValidationClientHelpers
    extend ::Gitlab::Utils::Override
    override :secure_analyzers_prefix

    def stub_content_validation_settings
      allow(::Gitlab).to receive(:com?).and_return(true)
      stub_application_setting(content_validation_endpoint_url: "https://content_validation.url")
      stub_application_setting(content_validation_api_key: "xxx")
      stub_application_setting(content_validation_endpoint_enabled: true)
    end

    def stub_content_validation_request(ret)
      allow(::Gitlab).to receive(:com?).and_return(true)
      endpoint = 'https://content_validation.url'
      api_key = 'abcdefghijklmnopqrstuvwxyz'
      url = "#{endpoint}/api/content_validation/validate"
      stub_application_setting(content_validation_endpoint_url: endpoint)
      stub_application_setting(content_validation_api_key: api_key)
      stub_application_setting(content_validation_endpoint_enabled: true)

      if ret
        WebMock.stub_request(:post, url)
        .to_return(
          status: 200,
          body: ::Gitlab::Json.dump({ 'code' => 200, 'message' => 'validation success"' }),
          headers: { "Content-Type" => "application/json" }
        )
      else
        WebMock.stub_request(:post, url)
        .to_return(
          status: 406,
          body: ::Gitlab::Json.dump({ code: 406, message: "validation block" }),
          headers: { "Content-Type" => "application/json" }
        )
      end
    end

    def disable_content_validation
      allow(::Gitlab).to receive(:com?).and_return(true)
      endpoint = 'https://content_validation.url'
      api_key = 'abcdefghijklmnopqrstuvwxyz'
      url = "#{endpoint}/api/content_validation/validate"
      stub_application_setting(content_validation_endpoint_url: endpoint)
      stub_application_setting(content_validation_api_key: api_key)
      stub_application_setting(content_validation_endpoint_enabled: false)

      WebMock.stub_request(:post, url)
      .to_return(
        status: 406,
        body: ::Gitlab::Json.dump({ code: 406, message: "validation block" }),
        headers: { "Content-Type" => "application/json" }
      )
    end
  end
end

RSpec.configure do |config|
  config.include JH::ContentValidationClientHelpers
end
