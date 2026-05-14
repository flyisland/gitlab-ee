# frozen_string_literal: true

module EE
  module WorkItems
    module TypesFramework
      module HasType
        extend ::Gitlab::Utils::Override

        private

        override :persistable_type_id
        def persistable_type_id(type)
          return super unless type.respond_to?(:converted_from_system_defined_type_identifier)

          # Converted custom types must persist the system-defined type ID they replaced,
          # not their own AR primary key. This ensures existing queries, indexes, and
          # foreign key references continue to use the system-defined ID without needing
          # OR conditions.
          type.converted_from_system_defined_type_identifier || type.id
        end
      end
    end
  end
end
