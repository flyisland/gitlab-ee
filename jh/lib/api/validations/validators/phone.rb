# frozen_string_literal: true

module API
  module Validations
    module Validators
      class Phone < Grape::Validations::Validators::Base
        MAX_LENGTH = 20

        def validate_param!(attr_name, params)
          value = params[attr_name]

          if value.size > MAX_LENGTH
            raise Grape::Exceptions::Validation.new(
              params: [@scope.full_name(attr_name)],
              message: "must be less than #{MAX_LENGTH} characters"
            )
          end

          begin
            ::JH::Sms::TencentSms.validate_phone_number!(value)
          rescue ::JH::Sms::TencentSms::PhoneNumberError => e
            raise Grape::Exceptions::Validation.new(
              params: [@scope.full_name(attr_name)],
              message: e.message
            )
          end
        end
      end
    end
  end
end
