# frozen_string_literal: true

module EE
  module Groups
    module SavedViewsController
      extend ActiveSupport::Concern

      prepended do
        before_action do
          push_frontend_feature_flag(:work_item_configurable_types, group.root_ancestor)
        end
      end
    end
  end
end
