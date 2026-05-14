# frozen_string_literal: true

module EE
  module Types
    module WorkItems
      module TypeType
        extend ActiveSupport::Concern

        def supported_conversion_types
          resolve_types_through_provider(super)
        end

        private

        def resolve_types_through_provider(types)
          return types if types.blank?

          provider.by_ids_ordered_by_name(types.map(&:id))
        end

        def provider
          @provider ||= ::WorkItems::TypesFramework::Provider.new(context[:resource_parent])
        end
      end
    end
  end
end
