# frozen_string_literal: true

module JH
  module RegistrationsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    include PhoneRegistrationsHelper
    include CheckPhoneAndCode

    prepended do
      prepend_before_action :set_phone_resource_fields, only: [:create], if: :registration_by_phone?
      before_action :verify_code_received_by_phone, only: [:create], if: :registration_by_phone?
    end

    private

    override :skip_confirmation?
    def skip_confirmation?
      super || registration_by_phone?
    end

    def set_phone_resource_fields
      set_default_first_and_last_name
      params[user_resource_key][:email] = temporarily_email
    end

    def temporarily_email
      hostname = ::Gitlab::CurrentSettings.current_application_settings.commit_email_hostname
      "temp-email-for-phone-#{SecureRandom.uuid}@#{hostname}"
    end

    def verify_code_received_by_phone
      message = check_verification_code

      return unless message

      set_user_original_phone(resource)
      flash[:alert] = message

      render :new, registration_type: registration_type
    end

    override :sign_up_params_attributes
    def sign_up_params_attributes
      super.tap do |attributes|
        attributes << [:phone] if registration_by_phone?
      end
    end

    def set_user_original_phone(new_user)
      new_user.phone = params.dig(:user, :original_phone) if new_user&.new_record?
    end

    override :after_successful_create_hook
    def after_successful_create_hook(new_user)
      super

      set_user_original_phone(new_user)
    end

    def set_default_first_and_last_name
      return unless params[user_resource_key]

      params[user_resource_key][:first_name] = params[user_resource_key][:username]
      params[user_resource_key][:last_name] = 'User'
    end
  end
end
