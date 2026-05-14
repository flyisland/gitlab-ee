# frozen_string_literal: true

module EE
  module API
    module Helpers
      module WorkItems
        module Preloads
          extend ::Gitlab::Utils::Override

          EE_FEATURE_PRELOADS = {
            health_status: [],
            color: [:color],
            progress: [:progress],
            iteration: [{ iteration: :group }],
            weight: [:weights_source],
            start_and_due_date: [
              {
                dates_source: {
                  start_date_sourcing_work_item: [:work_item_type, { namespace: :route }],
                  due_date_sourcing_work_item: [:work_item_type, { namespace: :route }],
                  start_date_sourcing_milestone: [:group],
                  due_date_sourcing_milestone: [:group]
                }
              }
            ]
          }.freeze

          override :preload_associations_for
          def preload_associations_for(field_keys, feature_keys, resource_parent)
            preloads = super

            ee_preloads = feature_keys.flat_map do |feature|
              EE_FEATURE_PRELOADS.fetch(feature, [])
            end

            (preloads + ee_preloads).uniq
          end
        end
      end
    end
  end
end
