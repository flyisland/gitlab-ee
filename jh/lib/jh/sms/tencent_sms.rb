# frozen_string_literal: true

module JH
  module Sms
    module TencentSms
      extend AreaCode
      include ::TencentCloud::Common
      include ::TencentCloud::Sms::V20210111

      PhoneNumberError = Class.new(StandardError)

      def self.send_code(phone)
        validate_phone_number!(phone)

        cre = Credential.new(Sms.config.secret_id, Sms.config.secret_key)
        cli = Client.new(cre, Sms.config.region)
        random_code = (SecureRandom.random_number(9e5) + 1e5).to_i.to_s

        phonenumberset = [phone.to_s]
        smssdkappid = Sms.config.app_id
        templateid = Sms.config.template_id_zh
        signname = Sms.config.sign_name_zh
        templateparamset = [random_code, "10"]
        extendcode = nil
        sessioncontext = nil
        senderid = nil

        unless mainland? phone
          templateid = Sms.config.template_id_en
          signname = Sms.config.sign_name_en
          templateparamset = [random_code]
        end

        req = SendSmsRequest.new(
          phonenumberset,
          smssdkappid,
          templateid,
          signname,
          templateparamset,
          extendcode,
          sessioncontext,
          senderid
        )
        cli.SendSms(req)
        random_code
      rescue TencentCloudSDKException, PhoneNumberError => e
        ::Gitlab::AppLogger.error(e)
        nil
      end

      def self.validate_phone_number!(phone)
        raise PhoneNumberError, "Invalid Phone Number" unless phone&.match?(/^\+\d+$/)
        raise PhoneNumberError, "Unsupported Region Phone Number" unless with_valid_area_code?(phone)

        len = phone.length
        if mainland? phone
          raise PhoneNumberError, "Invalid China Mainland Phone Number" if len != 14
        elsif hongkong? phone
          raise PhoneNumberError, "Invalid China HongKong Phone Number" if len > 12 || len < 11
        elsif macao? phone
          raise PhoneNumberError, "Invalid China Macao Phone Number" if len > 12 || len < 11
        end
      end
    end
  end
end
