# frozen_string_literal: true

module EE
  module Projects
    module SavedViewsController
      extend ActiveSupport::Concern

      prepended do
        before_action do
          push_frontend_feature_flag(:work_item_configurable_types, project.root_namespace)
        end
      end
    end
  end
end
