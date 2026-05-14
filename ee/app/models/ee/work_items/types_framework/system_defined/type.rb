# frozen_string_literal: true

module EE
  module WorkItems
    module TypesFramework
      module SystemDefined
        module Type
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          prepended do
            include ::WorkItems::OrganizationLicenseCheck
          end

          BASE_TYPES = [
            ::WorkItems::TypesFramework::SystemDefined::Definitions::Epic.configuration,
            ::WorkItems::TypesFramework::SystemDefined::Definitions::KeyResult.configuration,
            ::WorkItems::TypesFramework::SystemDefined::Definitions::Objective.configuration,
            ::WorkItems::TypesFramework::SystemDefined::Definitions::Requirement.configuration,
            ::WorkItems::TypesFramework::SystemDefined::Definitions::TestCase.configuration
          ].freeze

          class_methods do
            extend ::Gitlab::Utils::Override

            override :fixed_items
            def fixed_items
              super + BASE_TYPES
            end
          end

          # Long-term these per-type predicates should be replaced with a single is_base_type?(name)
          # method to avoid meta-programming and method_missing issues between CE/EE type classes.
          # See https://gitlab.com/gitlab-org/gitlab/-/work_items/592881
          BASE_TYPES.each do |type|
            define_method :"#{type[:base_type]}?" do
              base_type == type[:base_type]
            end
          end

          override :widgets
          def widgets(resource_parent)
            # Only include widgets if the resource_parent has the appropriate license or if the widget is not licensed
            super.reject { |widget_def| !widget_def.licensed?(resource_parent) }
          end

          def status_lifecycle_for(namespace_id)
            custom_lifecycle_for(namespace_id) || system_defined_lifecycle
          end

          def custom_status_enabled_for?(namespace_id)
            return false unless namespace_id

            ::WorkItems::TypeCustomLifecycle.exists?(
              work_item_type_id: id,
              namespace_id: namespace_id
            )
          end

          def custom_lifecycle_for(namespace_id)
            return unless namespace_id

            ::WorkItems::Statuses::Custom::Lifecycle
              .includes(:statuses, :default_open_status, :default_closed_status, :default_duplicate_status)
              .joins(:type_custom_lifecycles)
              .find_by(
                namespace_id: namespace_id,
                type_custom_lifecycles: { work_item_type_id: id, namespace_id: namespace_id }
              )
          end

          def system_defined_lifecycle
            ::WorkItems::Statuses::SystemDefined::Lifecycle.of_work_item_base_type(base_type)
          end

          override :filterable_list_view?
          def filterable_list_view?(resource_parent)
            return super unless licensed?
            return false unless feature_available_for_resource?(resource_parent, license_name.to_sym)

            super
          end

          private

          override :supported_conversion_base_types
          def supported_conversion_base_types(resource_parent, user)
            return [] unless supports_conversion?

            ce_types = super - ee_base_type_names
            ee_types = licensed_conversion_types(resource_parent)
            ee_types = filter_conversion_types(ee_types, resource_parent, user)

            ce_types + ee_types
          end

          override :authorized_types
          def authorized_types(types, resource_parent, licenses_for_relation)
            return super unless licenses_for_relation

            types.select do |type|
              license_name = licenses_for_relation[type.base_type]
              next type unless license_name

              resource_parent&.licensed_feature_available?(license_name)
            end
          end

          def supports_conversion?
            value = configuration_class.try(:supports_conversion?)
            value.nil? || value
          end

          def epic_allowed?(resource_parent, user)
            group = extract_group_from_resource(resource_parent)
            group && Ability.allowed?(user, :create_epic, group)
          end

          def ee_base_type_names
            BASE_TYPES.pluck(:base_type) # rubocop:disable Database/AvoidUsingPluckWithoutLimit -- It's an array of hashed not active record relations
          end

          def licensed_conversion_types(resource_parent)
            self.class.all.filter_map do |type|
              next unless type.licensed? && type.can_be_conversion_target?
              next unless feature_available_for_resource?(resource_parent, type.license_name.to_sym)

              type.base_type.to_s
            end
          end

          def filter_conversion_types(types, resource_parent, user)
            types -= %w[epic] unless epic_convertible?(resource_parent, user)
            types -= %w[objective key_result] unless okrs_enabled?(resource_parent)
            types
          end

          def epic_convertible?(resource_parent, user)
            issue? && epic_allowed?(resource_parent, user)
          end

          def okrs_enabled?(resource_parent)
            project = extract_project_from_resource(resource_parent)
            project && ::Feature.enabled?(:okrs_mvc, project)
          end

          def extract_group_from_resource(resource_parent)
            case resource_parent
            when ::Organizations::Organization
              nil
            when Group
              resource_parent
            else
              resource_parent&.group
            end
          end

          def extract_project_from_resource(resource_parent)
            if resource_parent.is_a?(Project)
              resource_parent
            elsif resource_parent.respond_to?(:project)
              resource_parent.project.presence
            end
          end
        end
      end
    end
  end
end
