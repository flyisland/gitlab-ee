# frozen_string_literal: true

module JH
  # ApplicationSetting JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the `ApplicationSetting` model
  module ApplicationSetting
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      validates :content_validation_endpoint_url,
        addressable_url: ::ApplicationSetting::ADDRESSABLE_URL_VALIDATION_OPTIONS, allow_blank: true

      validates :content_validation_endpoint_url,
        presence: true,
        if: :content_validation_endpoint_enabled

      validates :content_validation_api_key,
        length: { maximum: 2000, message: ->(_object, _data) do
          _('is too long (maximum is %{count} characters)')
        end },
        allow_blank: true

      validates :content_validation_api_key,
        presence: true,
        if: :content_validation_endpoint_enabled

      attr_encrypted :content_validation_api_key, encryption_options_base_32_aes_256_gcm.merge(encode: false)

      validates :dingtalk_app_key,
        length: { maximum: 500, message: ->(_object, _data) do
          _('is too long (maximum is %{count} characters)')
        end },
        presence: true, if: :dingtalk_integration_enabled
      attr_encrypted :dingtalk_app_key, encryption_options_base_32_aes_256_gcm.merge(encode: false)

      validates :dingtalk_app_secret,
        length: { maximum: 500, message: ->(_object, _data) do
          _('is too long (maximum is %{count} characters)')
        end },
        presence: true, if: :dingtalk_integration_enabled
      attr_encrypted :dingtalk_app_secret, encryption_options_base_32_aes_256_gcm.merge(encode: false)

      validates :dingtalk_corpid,
        length: { maximum: 500, message: ->(_object, _data) do
          _('is too long (maximum is %{count} characters)')
        end },
        presence: true, if: :dingtalk_integration_enabled
      attr_encrypted :dingtalk_corpid, encryption_options_base_32_aes_256_gcm.merge(encode: false)

      validates :feishu_app_key,
        length: { maximum: 500, message: ->(_object, _data) do
          _('is too long (maximum is %{count} characters)')
        end },
        presence: true, if: :feishu_integration_enabled
      attr_encrypted :feishu_app_key, encryption_options_base_32_aes_256_gcm.merge(encode: false)

      validates :feishu_app_secret,
        length: { maximum: 500, message: ->(_object, _data) do
          _('is too long (maximum is %{count} characters)')
        end },
        presence: true, if: :feishu_integration_enabled
      attr_encrypted :feishu_app_secret, encryption_options_base_32_aes_256_gcm.merge(encode: false)

      validates :password_expiration_enabled,
        inclusion: { in: [true, false] }

      validates :password_expires_in_days,
        presence: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 14, less_than_or_equal_to: 400,
                        greater_than: :password_expires_notice_before_days }

      validates :password_expires_notice_before_days,
        presence: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 30 }

      validate :check_change_on_password_expiration_disabled
      validates :phone_verification_code_enabled,
        inclusion: { in: [true, false], message: N_('must be a boolean value') }
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      override :defaults

      def defaults
        super.merge(
          content_validation_enabled: false,
          content_validation_endpoint_url: nil,
          content_validation_api_key: nil,
          dingtalk_integration_enabled: false,
          dingtalk_corpid: nil,
          dingtalk_app_key: nil,
          dingtalk_app_secret: nil,
          feishu_integration_enabled: false,
          feishu_app_key: nil,
          feishu_app_secret: nil,
          password_expiration_enabled: false,
          password_expires_in_days: 90,
          password_expires_notice_before_days: 7
        )
      end
    end

    def ci_requires_identity_verification_on_free_plan
      false
    end

    OVERRIDE_SETTINGS = [
      :usage_ping_enabled,
      :version_check_enabled
    ].freeze

    def dingtalk_enabled?
      dingtalk_integration_enabled.present? &&
        dingtalk_app_key.present? &&
        dingtalk_app_secret.present? &&
        dingtalk_corpid.present?
    end

    def feishu_enabled?
      feishu_integration_enabled.present? &&
        feishu_app_secret.present? &&
        feishu_app_key.present?
    end

    def feishu_bot_enabled?
      feishu_integration_enabled.present? &&
        feishu_app_secret.present? &&
        feishu_app_key.present?
    end

    def check_change_on_password_expiration_disabled
      return if password_expiration_enabled

      error_message = s_('JH|can not be changed unless password expiration is enabled')
      errors.add(:password_expires_in_days, error_message) if password_expires_in_days_changed?
      errors.add(:password_expires_notice_before_days, error_message) if password_expires_notice_before_days_changed?
    end

    def disable_download_button_enabled?
      ::Gitlab::CurrentSettings.disable_download_button && ::License.feature_available?(:disable_download_button)
    end

    def usage_ping_enabled
      return false unless ::Feature.enabled?(:jh_usage_statistics)

      super
    end

    def version_check_enabled
      return false unless ::Feature.enabled?(:jh_usage_statistics)

      super
    end
  end
end
