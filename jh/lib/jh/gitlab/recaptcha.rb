# frozen_string_literal: true

# overwrite the Recaptcha domain to avoid getting blocked in China
module JH
  module Gitlab
    module Recaptcha
      ::Recaptcha.configure do |config|
        config.api_server_url = 'https://www.recaptcha.net/recaptcha/api.js'
        config.verify_url = 'https://www.recaptcha.net/recaptcha/api/siteverify'
      end
    end
  end
end
