# frozen_string_literal: true

require 'tencentcloud-sdk-common'
require 'tencentcloud-sdk-captcha'

module JH
  module Captcha
    module TencentCloud
      include ::TencentCloud::Common
      include ::TencentCloud::Captcha::V20190722

      def self.enabled?
        ::Gitlab.jh? && ::Gitlab.com? && ::Feature.enabled?(:tencent_captcha)
      end

      def self.verify!(ticket_rc, user_ip, rand_str)
        cre = Credential.new(ENV['TC_CAPTCHA_ID'], ENV['TC_CAPTCHA_KEY'])
        cli = Client.new(cre, 'ap-beijing')

        captchatype = 9
        ticket = ticket_rc
        userip = user_ip
        randstr = rand_str
        captchaappid = ENV['TC_CAPTCHA_APP_ID'].to_i
        appsecretkey = ENV['TC_CAPTCHA_APP_SECRET_KEY']
        businessid = nil
        sceneid = nil
        macaddress = nil
        imei = nil
        needgetcaptchatime = nil

        req = DescribeCaptchaResultRequest.new(
          captchatype,
          ticket,
          userip,
          randstr,
          captchaappid,
          appsecretkey,
          businessid,
          sceneid,
          macaddress,
          imei,
          needgetcaptchatime
        )
        res = cli.DescribeCaptchaResult(req)
        ::Gitlab::AppLogger.info(res.inspect)
        res.CaptchaCode == 1 && res.EvilLevel != 100
      rescue TencentCloudSDKException => e
        ::Gitlab::AppLogger.error(e)
        nil
      end
    end
  end
end
