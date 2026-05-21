# frozen_string_literal: true

module Resolvers
  module WorkItems
    class SettingsResolver < BaseResolver
      type ::Types::WorkItems::SettingsType, null: true

      def resolve
        feature_flag_actor = object.is_a?(::Organizations::Organization) ? nil : object.root_ancestor
        return unless Feature.enabled?(:work_item_configurable_types, feature_flag_actor)

        ::WorkItems::Settings.for_namespace(object)
      end
    end
  end
end
