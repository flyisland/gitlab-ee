# frozen_string_literal: true

module Resolvers
  module Ai
    class FlowTriggersResolver < BaseResolver
      include LooksAhead

      alias_method :project, :object

      type ::Types::Ai::FlowTriggerType.connection_type, null: true

      authorize :manage_ai_flow_triggers

      argument :ids, [::Types::GlobalIDType[::Ai::FlowTrigger]],
        required: false,
        default_value: nil,
        description: 'Filter AI flow triggers by IDs.'

      def resolve_with_lookahead(ids: nil)
        triggers = project.ai_flow_triggers
        triggers = triggers.with_ids(ids.map(&:model_id)) if ids

        apply_lookahead(triggers)
      end

      private

      def preloads
        {
          user: [
            :user,
            :autonomous_service_account,
            { ai_catalog_item_consumer: [:service_account, { parent_item_consumer: :service_account }] }
          ],
          ai_catalog_item_consumer: { ai_catalog_item_consumer: [:item, :project] },
          precondition: { ai_catalog_item_consumer: :item }
        }
      end
    end
  end
end
