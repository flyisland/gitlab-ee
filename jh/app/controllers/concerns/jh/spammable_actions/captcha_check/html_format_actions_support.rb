# frozen_string_literal: true

module JH
  module SpammableActions::CaptchaCheck::HtmlFormatActionsSupport
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    private

    override :convert_html_spam_params_to_headers
    def convert_html_spam_params_to_headers
      super

      return unless params['jh_captcha_response']

      request.headers['X-GitLab-Captcha-Response'] = params['jh_captcha_response']
    end
  end
end
