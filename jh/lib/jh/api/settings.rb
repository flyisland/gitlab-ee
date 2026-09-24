# frozen_string_literal: true

module JH
  module API
    module Settings
      extend ActiveSupport::Concern

      prepended do
        helpers do
          extend ::Gitlab::Utils::Override

          # rubocop:disable Metrics/CyclomaticComplexity
          # rubocop:disable Metrics/PerceivedComplexity
          override :filter_attributes_using_license
          def filter_attributes_using_license(attrs)
            super_attrs = super
            attrs = super_attrs

            unless ::Gitlab::PasswordExpirationSystem.visible?
              attrs = attrs.except(*JH::ApplicationSettingsHelper.password_expiration_attributes)
            end

            attrs
          end
          # rubocop:enable Metrics/CyclomaticComplexity
          # rubocop:enable Metrics/PerceivedComplexity
        end
      end
    end
  end
end
