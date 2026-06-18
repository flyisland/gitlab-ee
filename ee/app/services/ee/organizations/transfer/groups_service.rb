# frozen_string_literal: true

module EE
  module Organizations
    module Transfer
      module GroupsService
        extend ::Gitlab::Utils::Override
        include ::Gitlab::Utils::StrongMemoize

        override :perform_transfer
        def perform_transfer
          super

          transfer_subscriptions
          transfer_ai_catalog_items
        end

        private

        def transfer_subscriptions
          update_organization_id_for(::GitlabSubscriptions::AddOnPurchase) { |relation| relation.by_namespace(group) }
          update_organization_id_for(::GitlabSubscriptions::SeatAssignment) { |relation| relation.by_namespace(group) }

          update_organization_id_for(::GitlabSubscriptions::UserAddOnAssignment) do |relation|
            relation.for_add_on_purchases(add_on_purchases_relation)
          end

          update_organization_id_for(::GitlabSubscriptions::UserAddOnAssignmentVersion) do |relation|
            relation.for_add_on_purchases(add_on_purchases_relation)
          end
        end

        def add_on_purchases_relation
          ::GitlabSubscriptions::AddOnPurchase.by_namespace(group)
        end
        strong_memoize_attr :add_on_purchases_relation

        # rubocop:disable CodeReuse/ActiveRecord -- Query specific to this service
        def transfer_ai_catalog_items
          project_ids = ::Project.in_namespace(group.self_and_descendant_ids(skope: ::Namespace)).select(:id)

          update_organization_id_for(::Ai::Catalog::Item) do |relation|
            relation.where(project_id: project_ids)
          end
        end
        # rubocop:enable CodeReuse/ActiveRecord
      end
    end
  end
end
