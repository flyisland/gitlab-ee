# frozen_string_literal: true

module EE
  module API
    module Entities
      module WorkItems
        module Features
          module DetailEntity
            extend ActiveSupport::Concern

            prepended do
              expose_feature :color,
                widget_name: :color,
                using: ::API::Entities::WorkItems::Features::Color,
                documentation: { type: 'Entities::WorkItems::Features::Color' },
                expose_nil: true

              expose_feature :progress,
                widget_name: :progress,
                using: ::API::Entities::WorkItems::Features::Progress,
                documentation: { type: 'Entities::WorkItems::Features::Progress' },
                expose_nil: true

              expose_feature :iteration,
                widget_name: :iteration,
                using: ::API::Entities::WorkItems::Features::Iteration,
                documentation: { type: 'Entities::WorkItems::Features::Iteration' },
                expose_nil: true

              expose_feature :health_status,
                widget_name: :health_status,
                using: ::API::Entities::WorkItems::Features::HealthStatusDetail,
                documentation: { type: 'Entities::WorkItems::Features::HealthStatusDetail' },
                expose_nil: true

              expose_feature :weight,
                widget_name: :weight,
                using: ::API::Entities::WorkItems::Features::Weight,
                documentation: { type: 'Entities::WorkItems::Features::Weight' },
                expose_nil: true
            end
          end
        end
      end
    end
  end
end
