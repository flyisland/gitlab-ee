# frozen_string_literal: true

module Sidebars
  module YourWork
    module Menus
      class PerformanceMeasurementMenu < ::Sidebars::Menu
        override :link
        def link
          performance_measurement_index_path
        end

        override :title
        def title
          s_('JH|PerformanceMeasurement|Performance Measurement')
        end

        override :sprite_icon
        def sprite_icon
          'status-health'
        end

        override :render?
        def render?
          !!context.current_user && ::Feature.enabled?(:jh_new_performance_measurement, context.current_user)
        end

        override :active_routes
        def active_routes
          {
            path: 'performance_measurement#index'
          }
        end
      end
    end
  end
end
