# frozen_string_literal: true

module EE
  module API
    module Helpers
      module WorkItems
        module ListParams
          extend ActiveSupport::Concern

          prepended do
            params :work_items_filter_params_ee do
              optional :iteration_id, type: Integer,
                desc: 'Filter by iteration ID.'
              optional :iteration_wildcard_id, type: String,
                values: %w[None Any Current],
                desc: 'Filter by iteration wildcard. Values: None, Any, or Current.'
              mutually_exclusive :iteration_id, :iteration_wildcard_id

              optional :iteration_cadence_id, type: Array[Integer],
                desc: 'Filter by iteration cadence IDs.',
                coerce_with: ::API::Validations::Types::CommaSeparatedToIntegerArray.coerce

              optional :health_status_filter, type: String,
                values: %w[none any on_track needs_attention at_risk],
                desc: 'Filter by health status. Values: none, any, on_track, needs_attention, or at_risk.'

              optional :weight, type: String,
                desc: 'Filter by weight. Supports specific weight values, "none", and "any".'
              optional :weight_wildcard_id, type: String,
                values: %w[None Any],
                desc: 'Filter by weight wildcard. Values: None or Any.'
              mutually_exclusive :weight, :weight_wildcard_id
            end

            params :work_items_not_filter_params_ee do
              optional :iteration_id, type: Integer,
                desc: 'Exclude work items in this iteration.'
              optional :iteration_wildcard_id, type: String,
                values: %w[None Any Current],
                desc: 'Exclude by iteration wildcard. Values: None, Any, or Current.'
              mutually_exclusive :iteration_id, :iteration_wildcard_id

              optional :health_status_filter, type: Array[String],
                values: ::Issue.health_statuses.keys,
                desc: 'Exclude work items with these health statuses.',
                coerce_with: ::API::Validations::Types::CommaSeparatedToArray.coerce

              optional :weight, type: String,
                desc: 'Exclude work items with this weight.'
            end
          end
        end
      end
    end
  end
end
