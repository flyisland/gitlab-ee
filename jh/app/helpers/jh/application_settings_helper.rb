# frozen_string_literal: true

module JH
  module ApplicationSettingsHelper
    extend ::Gitlab::Utils::Override

    override :visible_attributes

    def visible_attributes
      attrs = super + [
        :content_validation_endpoint_enabled,
        :content_validation_endpoint_url,
        :content_validation_api_key,
        :disable_download_button,
        :phone_verification_code_enabled
      ]

      integrations_attrs = if !::Gitlab.com? && ::Gitlab.jh?
                             [
                               :dingtalk_integration_enabled,
                               :dingtalk_corpid,
                               :dingtalk_app_key,
                               :dingtalk_app_secret,
                               :feishu_integration_enabled,
                               :feishu_app_key,
                               :feishu_app_secret
                             ]
                           else
                             []
                           end

      attrs + integrations_attrs
    end

    def self.possible_licensed_attributes
      EE::ApplicationSettingsHelper.possible_licensed_attributes + password_expiration_attributes
    end

    def self.password_expiration_attributes
      %i[
        password_expiration_enabled
        password_expires_in_days
        password_expires_notice_before_days
      ]
    end
  end
end
