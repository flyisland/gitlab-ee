# frozen_string_literal: true

module Gitlab
  module Captcha
    module TencentCaptcha
      def self.tencent_captcha_enabled
        true # replace to ::Gitlab::CurrentSettings.tencent_captcha_enabled when it's ready
      end
    end
  end
end
