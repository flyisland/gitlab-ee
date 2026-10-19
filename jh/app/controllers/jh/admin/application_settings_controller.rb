# frozen_string_literal: true

module JH
  module Admin
    module ApplicationSettingsController
      extend ::Gitlab::Utils::Override
      extend ActiveSupport::Concern

      def visible_application_setting_attributes
        attrs = super

        if ::Gitlab::PasswordExpirationSystem.visible?
          attrs += JH::ApplicationSettingsHelper.password_expiration_attributes
        end

        attrs
      end
    end
  end
end
