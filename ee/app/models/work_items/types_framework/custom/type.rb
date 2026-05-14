# frozen_string_literal: true

module WorkItems
  module TypesFramework
    module Custom
      class Type < ApplicationRecord
        self.table_name = 'work_item_custom_types'

        include ActiveRecord::FixedItemsModel::HasOne

        MAX_TYPE_PER_PARENT = 40

        # These names are reserved to prevent conflicts with existing GitLab features
        # and potential future work item types. Users cannot create custom work item
        # types with these names. See https://gitlab.com/gitlab-org/gitlab/-/issues/583832
        RESERVED_NAMES = %w[
          vulnerability
          merge_request
          commit
          pipeline
          alert
          review
          diff
          report
          sha
        ].freeze

        belongs_to :organization, class_name: 'Organizations::Organization', optional: true
        belongs_to :namespace, optional: true
        belongs_to_fixed_items :converted_from_system_defined_type,
          fixed_items_class: WorkItems::TypesFramework::SystemDefined::Type,
          foreign_key: 'converted_from_system_defined_type_identifier'

        enum :icon_name, ::WorkItems::TypesFramework::IconDefinitions::ENUM_MAPPING, validate: {
          message: ->(_object, _data) {
            format(_("is not valid. Valid icon names are: %{valid_names}"),
              valid_names: icon_names.keys.sort.join(', '))
          }
        }

        before_validation :strip_whitespaces

        validates :name, presence: true
        validates :name, length: { maximum: 48 }
        validates :icon_name, presence: true
        validates :name, uniqueness: { case_sensitive: false, scope: [:organization_id, :namespace_id] }

        validates_with ExactlyOnePresentValidator, fields: :sharding_keys

        validate :system_defined_names_unique_across_parent_scope
        validate :reserved_name_not_used
        validate :max_types_per_parent_limit, on: :create
        validate :unarchiving_within_limit, on: :update

        scope :for_organization, ->(organization) { where(organization_id: organization.id) }
        scope :for_namespace, ->(namespace) { where(namespace_id: namespace.id) }
        scope :order_by_name_asc, -> { order(arel_table[:name].lower.asc) }
        scope :active, -> { where(archived: false) }

        # Until we have widget customization etc. we can simply delegate to the system defined type
        delegate :supported_conversion_types, :widgets, :widget_definitions, :base_type, :widget_classes,
          :allowed_child_types, :allowed_parent_types, :descendant_types,
          :supports_roadmap_view?, :use_legacy_view?, :can_promote_to_objective?, :show_project_selector?,
          :supports_move_action?, :service_desk?, :incident_management?, :configurable?, :creatable?,
          :visible_in_settings?, :only_for_group?, :enabled?, :system_defined_lifecycle,
          :custom_status_enabled_for?, :filterable_list_view?, :filterable_board_view?,
          :disabled_workflow_type?, :okr?,
          to: :delegation_source

        # Long-term these per-type predicates should be replaced with a single is_base_type?(name)
        # method to avoid meta-programming and method_missing issues between CE/EE type classes.
        # See https://gitlab.com/gitlab-org/gitlab/-/work_items/592881
        WorkItems::TypesFramework::SystemDefined::Type.fixed_items.each do |type|
          delegate :"#{type[:base_type]}?", to: :delegation_source
        end

        def to_global_id(_options = {})
          converted_from_system_defined_type&.to_global_id ||
            ::Gitlab::GlobalId.build(self, model_name: 'WorkItems::Type', id: id)
        end
        alias_method :to_gid, :to_global_id

        def parent
          organization || namespace
        end

        def non_converted_custom_type?
          converted_from_system_defined_type_identifier.nil?
        end

        def delegation_source
          # use the associated system defined type as delegation source if set otherwise default to issue base type
          converted_from_system_defined_type || ::WorkItems::TypesFramework::Provider.new.default_issue_type
        end

        def status_lifecycle_for(namespace_param_id)
          custom_lifecycle_for(namespace_param_id) || system_defined_lifecycle
        end

        def custom_lifecycle_for(namespace_param_id)
          if converted_from_system_defined_type_identifier.present?
            find_custom_lifecycle_for(converted_from_system_defined_type_identifier, namespace_param_id)
          else
            find_custom_lifecycle_for(id, namespace_param_id)
          end
        end

        private

        def strip_whitespaces
          self.name = name&.strip
        end

        def sharding_keys
          [:namespace_id, :organization_id]
        end

        def find_custom_lifecycle_for(id, namespace_param_id)
          return unless id.present? && namespace_param_id.present?

          ::WorkItems::Statuses::Custom::Lifecycle
            .includes(:statuses, :default_open_status, :default_closed_status, :default_duplicate_status)
            .joins(:type_custom_lifecycles)
            .find_by(
              namespace_id: namespace_param_id,
              type_custom_lifecycles: { work_item_type_id: id, namespace_id: namespace_param_id }
            )
        end

        def normalize_name(value)
          value.downcase.gsub(/[\s-]+/, '_')
        end

        def reserved_name_not_used
          return if name.blank?

          normalized = normalize_name(name)
          return unless RESERVED_NAMES.include?(normalized)

          display_name = normalized.tr('_', ' ').titleize
          errors.add(:name, format(_("'%{name}' is a reserved name and cannot be used."), name: display_name))
        end

        def system_defined_names_unique_across_parent_scope
          return if name.blank?

          normalized_input = normalize_name(name)
          system_type = WorkItems::TypesFramework::SystemDefined::Type.all.find do |t|
            normalize_name(t.name) == normalized_input
          end

          return unless system_type

          # Allow the same name if this custom type is converted from that exact system defined type
          return if converted_from_system_defined_type_identifier == system_type.id

          # Allow if the system-defined name is available across namespace/organization
          # i.e a type was converted from the :issue type but renamed to something else, so "Issue" is still available
          return if system_defined_name_available?(system_type)

          errors.add(:name, format(_("'%{name}' is already taken."), name: system_type.name))
        end

        def system_defined_name_available?(system_type)
          converted_type = self.class
            .where(parent_scope_conditions)
            .excluding(self)
            .find_by(converted_from_system_defined_type_identifier: system_type.id)

          # Name is available if there's a converted type that uses a DIFFERENT name
          # than the system defined type it was converted from
          converted_type.present? && !(converted_type.name.casecmp(system_type.name) == 0)
        end

        def max_types_per_parent_limit
          return unless organization_id.present? || namespace_id.present?
          return unless total_types_count > MAX_TYPE_PER_PARENT

          parent_attribute = organization_id.present? ? :organization : :namespace

          errors.add(parent_attribute,
            format(_('can only have a maximum of %{limit} work item types.'), limit: MAX_TYPE_PER_PARENT)
          )
        end

        def total_types_count
          active_custom_types_count + system_defined_types_count
        end

        def active_custom_types_count
          self.class
            .where(parent_scope_conditions)
            .where(converted_from_system_defined_type_identifier: nil)
            .active
            .count
        end

        def system_defined_types_count
          provider = WorkItems::TypesFramework::Provider.new(parent)
          provider.available_system_defined_types_count - archived_converted_types_count
        end

        def archived_converted_types_count
          self.class
            .where(parent_scope_conditions)
            .where.not(converted_from_system_defined_type_identifier: nil)
            .where(archived: true)
            .count
        end

        def unarchiving_within_limit
          return unless archived_changed?(from: true, to: false)
          return unless total_types_count >= MAX_TYPE_PER_PARENT

          errors.add(:base,
            format(_('Cannot unarchive because the maximum limit of %{limit} work item types has been reached.'),
              limit: MAX_TYPE_PER_PARENT)
          )
        end

        def parent_scope_conditions
          if organization_id.present?
            { organization_id: organization_id }
          else
            { namespace_id: namespace_id }
          end
        end
      end
    end
  end
end
