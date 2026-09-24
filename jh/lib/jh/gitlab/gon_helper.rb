# frozen_string_literal: true

module JH
  module Gitlab
    module GonHelper
      extend ::Gitlab::Utils::Override

      # rubocop: disable Metrics/AbcSize -- Generate dynamic variables with its condition as per
      override :add_gon_variables
      def add_gon_variables
        super

        gon.recaptcha_enabled = ::Gitlab::CurrentSettings.recaptcha_enabled
        gon.tencent_captcha_enabled = true
        gon.tencent_captcha_replacement_enabled = ::JH::Captcha::TencentCloud.enabled?
        gon.tencent_captcha_app_id = ENV['TC_CAPTCHA_APP_ID']
        gon.geetest_captcha_id = ENV['GEETEST_CAPTCHA_ID']
        gon.geetest_captcha_replacement_enabled = ::JH::Captcha::Geetest.enabled?
        gon.real_name_system = ::Gitlab::RealNameSystem.enabled?
        gon.phone_registration = ::Feature.enabled?(:registrations_with_phone)
        gon.customer_support_url = ::Gitlab::Saas.customer_support_url
        gon.content_validation_enabled = ::ContentValidation::Setting.content_validation_enable?
        gon.disable_download_button = ::Gitlab::CurrentSettings.disable_download_button_enabled?
        gon.has_active_license = ::EE::LicenseHelper.has_active_license?
        gon.current_user_is_auditor = current_user.auditor? if current_user

        push_frontend_feature_flag(:phone_authenticatable)
      end
      # rubocop: enable Metrics/AbcSize
    end
  end
end
