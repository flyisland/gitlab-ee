# frozen_string_literal: true

module Ai
  module Catalog
    module Concerns
      module DwsFlowConfigValidator
        extend ActiveSupport::Concern

        private

        def validate_flow_config_with_dws(definition_hash)
          return ServiceResponse.success unless Feature.enabled?(:ai_catalog_dws_validate_flow_config, current_user)
          return ServiceResponse.success if definition_hash.blank?

          config = definition_hash.except('yaml_definition')
          dws_client.validate_flow_config(flow_config: config)
        end

        def dws_client
          ::Ai::DuoWorkflow::DuoWorkflowService::Client.new(
            duo_workflow_service_url: ::Gitlab::DuoWorkflow::Client.url(user: current_user),
            current_user: current_user,
            secure: ::Gitlab::DuoWorkflow::Client.secure?
          )
        end

        def set_dws_validated_on_version(item_version)
          item_version.dws_flow_config_validated = true
        end
      end
    end
  end
end
