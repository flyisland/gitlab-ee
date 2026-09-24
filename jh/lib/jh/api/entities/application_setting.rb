# frozen_string_literal: true

module JH
  module API
    module Entities
      module ApplicationSetting
        extend ActiveSupport::Concern

        prepended do
          expose(*JH::ApplicationSettingsHelper.password_expiration_attributes, if: ->(_instance, _options) do
            ::Gitlab::PasswordExpirationSystem.visible?
          end)
        end
      end
    end
  end
end
