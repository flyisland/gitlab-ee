# frozen_string_literal: true

module JH
  module API
    module Helpers
      module SettingsHelpers
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :optional_attributes
          def optional_attributes
            super + JH::ApplicationSettingsHelper.possible_licensed_attributes
          end
        end
      end
    end
  end
end
