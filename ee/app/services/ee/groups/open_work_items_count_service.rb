# frozen_string_literal: true

module EE
  module Groups
    module OpenWorkItemsCountService
      extend ::Gitlab::Utils::Override

      private

      override :relation_for_count
      def relation_for_count
        excluded_types = non_filterable_base_types(group)
        return super if excluded_types.blank?

        super.without_issue_type(excluded_types)
      end

      def non_filterable_base_types(namespace)
        ::WorkItems::TypesFramework::Provider.new(namespace).all
          .reject(&:filterable_list_view?)
          .map(&:base_type)
      end
    end
  end
end
