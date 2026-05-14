# frozen_string_literal: true

module WorkItems
  module SettingsPermissions
    extend ActiveSupport::Concern

    private

    def can_access_work_item_settings?(resource, user)
      return false unless work_items_settings_available_for_resource?(resource)

      if resource.is_a?(Group) && resource.root?
        can?(user, :admin_custom_field, resource) ||
          can?(user, :admin_work_item_lifecycle, resource) ||
          can?(user, :create_work_item_type, resource) ||
          can?(user, :update_work_item_type, resource)
      else
        can?(user, :configure_work_item_type, resource)
      end
    end

    # Root groups always have access; subgroups and projects require the feature flag
    def work_items_settings_available_for_resource?(resource)
      (resource.is_a?(Group) && resource.root?) ||
        ::Feature.enabled?(:work_item_configurable_types, resource.root_ancestor)
    end
  end
end
