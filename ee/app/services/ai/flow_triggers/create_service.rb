# frozen_string_literal: true

module Ai
  module FlowTriggers
    class CreateService < BaseService
      def initialize(project:, current_user:)
        @project = project
        @current_user = current_user
      end

      def execute(params)
        if !new_external_agents_allowed? && creating_external_agent_trigger?(params)
          return disallow_new_external_agent_error
        end

        result = super do |params|
          project.ai_flow_triggers.create(params)
        end

        audit_flow_trigger('flow_trigger_created', result.payload) if result.success?
        result
      end

      def creating_external_agent_trigger?(params)
        return true if params[:config_path].present?

        ai_catalog_item_consumer = ai_catalog_item_consumer(params[:ai_catalog_item_consumer_id])

        return false if ai_catalog_item_consumer.nil?

        ai_catalog_item_consumer.item.third_party_flow?
      end
    end
  end
end
