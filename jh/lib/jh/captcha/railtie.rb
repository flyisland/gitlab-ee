# frozen_string_literal: true

module JH
  module Captcha
    module Railtie
      extend ActiveSupport::Concern

      included do
        ::Recaptcha.include JH::Captcha::Recaptcha
        ::Recaptcha::Adapters::ControllerMethods.include JH::Captcha::Adapters::ControllerMethods
        ::Recaptcha::Helpers.include JH::Captcha::Helpers
      end
    end
  end
end
