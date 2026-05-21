# frozen_string_literal: true

module EE
  module Projects
    module OpenWorkItemsCountService
      extend ::Gitlab::Utils::Override

      override :relation_for_count
      def relation_for_count
        excluded_types = non_filterable_base_types(project)
        return super if excluded_types.blank?

        super.without_issue_type(excluded_types)
      end

      private

      def non_filterable_base_types(resource_parent)
        ::WorkItems::TypesFramework::Provider.new(resource_parent).all
          .reject(&:filterable_list_view?)
          .map(&:base_type)
      end
    end
  end
end
