# frozen_string_literal: true

module JH
  module Captcha
    module Adapters
      module ControllerMethods
        extend ActiveSupport::Concern

        included do
          alias_method :google_verify_recaptcha, :verify_recaptcha

          private

          def verify_recaptcha(options = {})
            options[:response] = params[:jh_captcha_response] \
              if jh_captcha_enabled? && !options.key?(:response) && defined?(params).present?

            google_verify_recaptcha options
          end

          def jh_captcha_enabled?
            ::JH::Captcha::TencentCloud.enabled? || ::JH::Captcha::Geetest.enabled?
          end
        end
      end
    end
  end
end
