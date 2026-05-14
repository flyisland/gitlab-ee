# frozen_string_literal: true

module EE
  module API
    module Helpers
      module WorkItems
        module CreateParams
          extend ActiveSupport::Concern
          extend ::Grape::API::Helpers

          prepended do
            params :work_item_create_features_ee do
              optional :color, type: Hash, desc: 'Input for color feature.' do
                requires :color, type: String,
                  desc: 'Color of the work item as a hex code (for example, "#e24329").'
              end
            end
          end
        end
      end
    end
  end
end
