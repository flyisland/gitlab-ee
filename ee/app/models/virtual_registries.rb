# frozen_string_literal: true

module VirtualRegistries
  PACKAGE_TYPES = %i[maven].freeze

  def self.table_name_prefix
    'virtual_registries_'
  end

  def self.registries_count_for(group, registry_type:)
    registry_class = "::VirtualRegistries::Packages::#{registry_type.to_s.classify}::Registry".safe_constantize
    return 0 unless registry_class

    registry_class.for_group(group).size
  end

  def self.user_has_access?(group, current_user, permission = :read_virtual_registry)
    Ability.allowed?(current_user, permission, group.virtual_registry_policy_subject)
  end

  def self.any_registry_available?(group, current_user, permission = :read_virtual_registry)
    ::VirtualRegistries::Packages::Maven.virtual_registry_available?(group, current_user, permission) ||
      ::VirtualRegistries::Container.virtual_registry_available?(group, current_user, permission)
  end
end
