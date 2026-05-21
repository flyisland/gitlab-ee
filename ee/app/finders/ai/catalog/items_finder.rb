# frozen_string_literal: true

module Ai
  module Catalog
    class ItemsFinder
      def initialize(current_user, params: {})
        @current_user = current_user
        @params = params

        validate_organization!
      end

      def execute
        items = init_collection
        items = by_organization(items)
        items = by_project(items)
        items = include_foundational_items(items)
        items = by_item_type(items)
        items = by_id(items)
        items = by_search(items)
        apply_visibility_and_ordering(items)
      end

      private

      attr_reader :current_user, :params

      def include_foundational_items(items)
        return items unless params[:include_foundational_items]

        items.include_foundational_items(params[:organization].id)
      end

      def init_collection
        Item.not_deleted
      end

      def apply_visibility_and_ordering(items)
        return items.visible_to_user_with_priority_ordering(current_user) if apply_default_ordering?

        items = items.public_or_visible_to_user(current_user)
        case params[:sort]
        when :usage_count_desc
          items.order_by_last_30_day_usage_count_desc
        when :usage_count_asc
          items.order_by_last_30_day_usage_count_asc
        else
          items.order_by_catalog_priority
        end
      end

      def apply_default_ordering?
        return false if [:usage_count_desc, :usage_count_asc].include?(params[:sort])

        Feature.enabled?(:ai_catalog_items_priority_order, current_user)
      end

      def by_organization(items)
        return items unless params[:organization]

        items.in_organization(params[:organization])
      end

      def by_project(items)
        return items unless params[:project]

        items.for_project(params[:project])
      end

      def by_item_type(items)
        return items unless params[:item_type] || params[:item_types]

        items.with_item_type([params[:item_type], *params[:item_types]].compact)
      end

      def by_id(items)
        return items unless params[:id]

        items.id_in(params[:id])
      end

      def by_search(items)
        return items if params[:search].blank?

        items.search(params[:search])
      end

      def validate_organization!
        return if params[:organization].is_a?(::Organizations::Organization)

        raise ArgumentError, _('Organization parameter must be specified')
      end
    end
  end
end
