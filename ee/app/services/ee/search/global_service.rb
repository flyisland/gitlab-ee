# frozen_string_literal: true

module EE
  module Search
    module GlobalService
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize
      include ::Search::AdvancedAndZoektSearchable

      def elasticsearch_results
        ::Gitlab::Elastic::SearchResults.new(
          current_user,
          params[:search],
          elastic_projects,
          public_and_internal_projects: elastic_global,
          order_by: params[:order_by],
          sort: params[:sort],
          filters: filters
        )
      end

      override :zoekt_searchable_scope?
      def zoekt_searchable_scope?
        true
      end

      override :search_level
      def search_level
        :global
      end

      override :root_ancestor
      def root_ancestor; end

      override :zoekt_node_id
      def zoekt_node_id; end

      def zoekt_nodes
        @zoekt_nodes ||= ::Search::Zoekt::Node.for_search.searchable
      end

      def elasticsearchable_scope
        nil
      end

      def elastic_global
        true
      end

      def elastic_projects
        return if traversal_ids_authorization_ready?

        if current_user&.can_read_all_resources?
          :any
        elsif current_user
          current_user.authorized_projects.pluck_primary_key
        else
          []
        end
      end
      strong_memoize_attr :elastic_projects

      def zoekt_project_id; end

      def zoekt_group_id; end

      private

      def traversal_ids_authorization_ready?
        ::Elastic::DataMigrationService.migration_has_finished?(:backfill_traversal_ids_on_commits)
      end
    end
  end
end
