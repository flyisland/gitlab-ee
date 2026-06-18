# frozen_string_literal: true

module EE
  module Resolvers
    module Users
      module RecentlyViewedItemsResolver
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :available_types
        def available_types
          # When work_items_autocomplete is enabled, epics are included in work items
          # When disabled, we need to add epics separately
          if ::Feature.enabled?(:work_items_autocomplete, current_user)
            super
          else
            super + [::Gitlab::Search::RecentEpics]
          end
        end

        override :authorized_to_read_item?
        def authorized_to_read_item?(item)
          return Ability.allowed?(current_user, :read_epic, item) if item.is_a?(Epic)

          super
        end
      end
    end
  end
end
