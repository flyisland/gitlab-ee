# frozen_string_literal: true

module WorkItems
  module SharedPolicy
    extend ActiveSupport::Concern

    included do
      condition(:work_item_statuses_available, scope: :subject) do
        @subject.licensed_feature_available?(:work_item_status)
      end

      condition(:configurable_work_item_types_enabled, scope: :subject) do
        @subject.licensed_feature_available?(:configurable_work_item_types)
      end

      rule { can?(:read_work_item) & work_item_statuses_available }.policy do
        enable :read_work_item_lifecycle
        enable :read_work_item_status
      end

      rule { maintainer }.policy do
        # Configuring visibility, widgets, hierarchy. But not the type itself.
        enable :configure_work_item_type
      end

      rule { ~configurable_work_item_types_enabled }.policy do
        prevent :configure_work_item_type
      end
    end
  end
end
