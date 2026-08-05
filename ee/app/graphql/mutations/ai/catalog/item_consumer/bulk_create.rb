# frozen_string_literal: true

module Mutations
  module Ai
    module Catalog
      module ItemConsumer
        class BulkCreate < BaseMutation
          graphql_name 'AiCatalogItemConsumerBulkCreate'

          argument :item_id, ::Types::GlobalIDType[::Ai::Catalog::Item],
            required: true,
            description: 'Global ID of the catalog item to enable.'

          MAX_PROJECTS = 100

          argument :project_ids, [::Types::GlobalIDType[::Project]],
            required: true,
            validates: { length: { maximum: MAX_PROJECTS } },
            description: "Global IDs of the projects to enable the catalog item in (maximum #{MAX_PROJECTS})."

          argument :trigger_types, [GraphQL::Types::String],
            required: false,
            description: 'List of event types to create flow triggers for.'

          argument :trigger_filter, GraphQL::Types::JSON, # rubocop:disable Graphql/JSONType -- filter schema is not model backed, disabled for the same reason in Mutations::Ai::Catalog::ItemConsumer::Create
            required: false,
            experiment: { milestone: '19.1' },
            description: 'Filter conditions for the auto-created flow triggers, keyed by event type.'

          authorize :read_ai_catalog_item

          def resolve(item_id:, project_ids:, trigger_types: nil, trigger_filter: nil)
            unless Feature.enabled?(:ai_catalog_bulk_item_consumer_create, current_user)
              raise_resource_not_available_error!
            end

            item = authorized_find!(id: item_id)

            result = ::Ai::Catalog::ItemConsumers::EnqueueBulkCreateService
              .new(current_user:, item:, project_ids:, trigger_types:, trigger_filter:).execute

            { errors: result.errors }
          end
        end
      end
    end
  end
end
