# frozen_string_literal: true

module JH
  module Sidebars
    module YourWork
      module Panel
        extend ::Gitlab::Utils::Override

        override :configure_menus
        def configure_menus
          super

          add_menu(performance_measurement_menu)

          true
        end

        private

        def performance_measurement_menu
          ::Sidebars::YourWork::Menus::PerformanceMeasurementMenu.new(context)
        end
      end
    end
  end
end
