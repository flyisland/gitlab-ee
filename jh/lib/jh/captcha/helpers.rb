# frozen_string_literal: true

module JH
  module Captcha
    module Helpers
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :google_captcha_tags, :recaptcha_tags

          def recaptcha_tags(options = {})
            jh_captcha_enabled? ? jh_captcha_tags(options) : google_captcha_tags(options)
          end

          private

          def jh_captcha_tags(_options = {})
            '<div class="js-captcha"></div>'.html_safe
          end

          def jh_captcha_enabled?
            ::JH::Captcha::TencentCloud.enabled? || ::JH::Captcha::Geetest.enabled?
          end
        end
      end
    end
  end
end
