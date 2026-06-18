# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class FoundationalFlowStartParamsResolver
      def self.call(reference, container, user: nil)
        flow = ::Ai::Catalog::FoundationalFlow.find_by_reference(reference)
        return {} unless flow

        resolved_ref, resolved_version = resolve_with_overrides(flow, container, user)
        config_id, schema_version = resolved_ref.split('/', 2)

        {
          flow_config_id: config_id,
          flow_config_schema_version: schema_version,
          flow_version: resolved_version
        }
      end

      def self.resolve_with_overrides(flow, container, user)
        case flow.foundational_flow_reference
        when 'developer/v1'
          if Feature.enabled?(:duo_developer_orbit, user) && ::Ai::Orbit::Settings.killswitch_on?(user)
            return ['developer/v1', '2.0.0-orbit']
          end
        when 'fix_pipeline/v1'
          if Feature.enabled?(:fix_pipeline_next, container) ||
              Feature.enabled?(:fix_pipeline_next, container.root_ancestor)
            return ['fix_pipeline_next/v1', ::Ai::Catalog::FoundationalFlow::DEFAULT_FLOW_VERSION]
          end
        end

        [flow.foundational_flow_reference, flow.flow_version]
      end
      private_class_method :resolve_with_overrides
    end
  end
end
