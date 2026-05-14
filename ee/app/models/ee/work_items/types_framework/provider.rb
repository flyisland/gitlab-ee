# frozen_string_literal: true

module EE
  module WorkItems
    module TypesFramework
      module Provider
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override
        include ::Gitlab::Utils::StrongMemoize

        # CachedType wraps a work item type (system-defined or custom) with per-namespace
        # state like `enabled`. We use a delegator rather than adding attributes directly
        # to the type because SystemDefined::Type instances are singletons backed by
        # FixedItemsModel - they share the same object_id across all callers. Mutating
        # them would leak state between requests.
        #
        # The identity method overrides (class, is_a?, instance_of?) ensure that
        # FixedItemsModel's equality check (`other.instance_of?(self.class)`) sees
        # the wrapped type's class, keeping CachedType transparent to code that
        # compares types by identity.
        class CachedType < SimpleDelegator
          attr_accessor :enabled

          def initialize(type, enabled: true)
            super(type)
            @enabled = enabled
          end

          def class
            __getobj__.class
          end

          def is_a?(klass)
            __getobj__.is_a?(klass) || super
          end

          alias_method :kind_of?, :is_a?

          def instance_of?(klass)
            __getobj__.instance_of?(klass)
          end
        end

        def invalidate_cache!
          ::Gitlab::SafeRequestStore.delete(cache_key)
          clear_memoization(:indexed_cache)
        end

        override :allowed_types
        def allowed_types
          types = super

          types.reject!(&:disabled_workflow_type?)
          types |= [find_by_base_type(:epic)] if epics_enabled?
          types |= [find_by_base_type(:objective), find_by_base_type(:key_result)] if okrs_enabled?
          types
        end

        # TODO: Integrate filtering into .all
        # https://gitlab.com/gitlab-org/gitlab/-/work_items/585707
        override :filtered_types
        def filtered_types
          all
            .reject { |type| disabled_workflow_type_unavailable?(type) }
            .reject { |type| epic_unavailable?(type) }
            .reject { |type| okr_unavailable?(type) }
        end

        private

        override :resolve_by_id
        def resolve_by_id(id)
          return super unless feature_available?

          indexed_cache[id] || super
        end

        override :resolve_by_base_type
        def resolve_by_base_type(name)
          return super unless feature_available?

          system_type = ::WorkItems::TypesFramework::SystemDefined::Type.default_by_type(name)
          return unless system_type

          indexed_cache[system_type.id]
        end

        override :resolve_all
        def resolve_all
          return super unless feature_available?

          indexed_cache.values.uniq
        end

        # Memoized per Provider instance to avoid repeated SafeRequestStore hash lookups
        # when multiple resolve_* methods are called on the same provider.
        # The SafeRequestStore layer shares the built cache across Provider instances
        # within the same request, so the expensive build_indexed_lookup only runs once
        # per namespace per request.
        def indexed_cache
          ::Gitlab::SafeRequestStore.fetch(cache_key) { build_indexed_lookup }
        end
        strong_memoize_attr :indexed_cache

        def cache_key
          "work_items_types_provider:#{namespace.class.base_class.name}:#{namespace.id}"
        end

        def build_indexed_lookup
          custom = custom_types.to_a

          converted_system_type_ids = custom.filter_map(&:converted_from_system_defined_type_identifier).to_set
          system_defined = system_defined_types.reject { |type| converted_system_type_ids.include?(type.id) }

          sorted = (custom + system_defined).sort_by { |type| type.name.downcase }

          sorted.each_with_object({}) do |type, hash|
            cached = CachedType.new(type, enabled: true)
            cache_id = if type.respond_to?(:converted_from_system_defined_type_identifier) &&
                type.converted_from_system_defined_type_identifier
                         type.converted_from_system_defined_type_identifier
                       else
                         type.id
                       end

            hash[cache_id] = cached
            # Converted custom types are primarily indexed under the system-defined type ID
            # they replaced (so find_by_base_type and existing DB references resolve correctly).
            # We also index under the custom type's own AR ID so that round-trips through
            # fetch_work_item_type work: code that resolves a type from the cache, reads .id
            # from it (the AR PK), and passes it back through find_by_id will find the same
            # object. Without this, HasType#work_item_type= breaks for converted types because
            # it extracts .id (the custom AR PK) and looks it up again.
            # Both keys point to the same CachedType instance - no memory duplication.
            hash[type.id] = cached if cache_id != type.id
          end
        end

        def system_defined_types
          ::WorkItems::TypesFramework::SystemDefined::Type.all
        end

        # TODO: On self-managed instances, custom types are scoped to the organization,
        # not the root group. We should resolve at the organization level to avoid
        # per-root-group cache entries and queries.
        # See https://gitlab.com/gitlab-org/gitlab/-/work_items/593071
        def custom_types
          return ::WorkItems::TypesFramework::Custom::Type.for_organization(root_ancestor) if organization_namespace?

          ::WorkItems::TypesFramework::Custom::Type.for_namespace(root_ancestor)
        end

        # Memoized per Provider instance because this is called on every resolve_* entry
        # point. Each work item holds its own Provider (via HasType), so without memoization
        # the feature flag + traversal_ids check would run on every work_item_type access.
        def feature_available?
          return false if namespace.nil?

          return ::Feature.enabled?(:work_item_configurable_types, :instance) if organization_namespace?

          # Read the root ancestor ID directly from the traversal_ids column, which is
          # already loaded on the namespace record. This avoids the DB query that
          # namespace.root_ancestor would trigger (Namespace.find_by(id: traversal_ids.first)).
          # Falls back to root_ancestor for non-Namespace objects (e.g. Project) that
          # lack traversal_ids.
          root_id = namespace.try(:traversal_ids)&.first
          root_id ||= root_ancestor.id

          return false unless root_id
          return false if root_id == namespace.id && namespace.try(:user_namespace?)
          return false if root_ancestor.user_namespace?

          # Group.actor_from_id builds a lightweight Feature::ActorWrapper with just
          # the flipper_id string ("Group:42"), avoiding a full AR load of the root
          # ancestor. Feature.enabled? only needs the flipper_id to check gate state.
          actor = ::Group.actor_from_id(root_id)
          ::Feature.enabled?(:work_item_configurable_types, actor)
        end
        strong_memoize_attr :feature_available?

        def organization_namespace?
          namespace.is_a?(::Organizations::Organization)
        end

        def disabled_workflow_type_unavailable?(type)
          return false unless type.disabled_workflow_type?

          !requirements_enabled?
        end

        def epic_unavailable?(type)
          return false unless type.base_type.to_s == 'epic'

          !epics_enabled?
        end

        def okr_unavailable?(type)
          return false unless type.okr?

          !okrs_enabled?
        end

        def requirements_enabled?
          return false if resource_parent.nil?

          return License.feature_available?(:requirements) if organization_namespace?

          resource_parent.licensed_feature_available?(:requirements)
        end
        strong_memoize_attr :requirements_enabled?

        def epics_enabled?
          return false if resource_parent.nil?

          return License.feature_available?(:epics) if organization_namespace?
          return resource_parent.try(:project_epics_enabled?) if project_namespace?

          resource_parent.licensed_feature_available?(:epics)
        end
        strong_memoize_attr :epics_enabled?

        def okrs_enabled?
          return false if resource_parent.nil?

          return ::Feature.enabled?(:okrs_mvc, :instance) if organization_namespace?

          project_namespace? && resource_parent.okrs_mvc_feature_flag_enabled?
        end
        strong_memoize_attr :okrs_enabled?
      end
    end
  end
end
