# frozen_string_literal: true

module JH
  module Captcha
    module Geetest
      class << self
        def enabled?
          ::Gitlab.jh? && ::Gitlab.com? && ::Feature.enabled?(:geetest_captcha)
        end

        def captcha_id
          ENV.fetch('GEETEST_CAPTCHA_ID', '')
        end

        def captcha_key
          ENV.fetch('GEETEST_CAPTCHA_KEY', '')
        end

        def api_server
          'https://gcaptcha4.geetest.com'
        end

        def uri
          URI("#{api_server}/validate?captcha_id=#{captcha_id}")
        end

        def gen_token(lot_number)
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), captcha_key, lot_number)
        end

        def verify_request_body(params)
          lot_number = params[:lot_number] || ''
          captcha_output = params[:captcha_output] || ''
          pass_token = params[:pass_token] || ''
          gen_time = params[:gen_time] || ''
          data = { "lot_number" => lot_number,
                   "captcha_output" => captcha_output,
                   "pass_token" => pass_token,
                   "gen_time" => gen_time,
                   "sign_token" => gen_token(lot_number) }

          URI.encode_www_form(data)
        end

        def verify!(params)
          res = ::Gitlab::HTTP.post(uri, body: verify_request_body(params), headers: {
            'Content-Type' => 'application/x-www-form-urlencoded'
          })
          ::Gitlab::AppLogger.info(res.inspect)

          response = ::Gitlab::Json.parse(res.body)
          response['result'] == 'success'
        rescue StandardError => e
          ::Gitlab::AppLogger.error(e)
          nil
        end
      end
    end
  end
end
