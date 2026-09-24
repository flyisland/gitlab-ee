# frozen_string_literal: true

module JH
  module Captcha
    module Recaptcha
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :google_captcha_verify_via_api_call, :verify_via_api_call

          def verify_via_api_call(recaptcha_response, options)
            if ::JH::Captcha::Geetest.enabled?
              geetest_captcha_verify_via_api_call(recaptcha_response, options)
            elsif ::JH::Captcha::TencentCloud.enabled?
              tencent_captcha_verify_via_api_call(recaptcha_response, options)
            else
              google_captcha_verify_via_api_call(recaptcha_response, options)
            end
          end

          def tencent_captcha_verify_via_api_call(captcha_response, options)
            return false if captcha_response.blank?

            begin
              response_data = ::Gitlab::Json.parse(Base64.decode64(captcha_response), symbolize_names: true)
            rescue StandardError
              return false
            end

            ::JH::Captcha::TencentCloud.verify!(response_data[:ticket], options[:remote_ip], response_data[:rand_str])
          end

          def geetest_captcha_verify_via_api_call(captcha_response, _options)
            return false if captcha_response.blank?

            begin
              response_data = ::Gitlab::Json.parse(Base64.decode64(captcha_response), symbolize_names: true)
            rescue StandardError
              return false
            end

            ::JH::Captcha::Geetest.verify!(response_data)
          end
        end
      end
    end
  end
end
