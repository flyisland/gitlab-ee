# frozen_string_literal: true

module Ai
  module Catalog
    class FoundationalFlow
      module Definitions
        module RiskClassification
          module_function

          REFERENCE = 'risk_classification/v1'
          private_constant :REFERENCE

          CONTEXT_CATEGORY = 'agent_platform_risk_classification_context'
          private_constant :CONTEXT_CATEGORY

          def configuration
            {
              foundational_flow_reference: REFERENCE,
              display_name: s_(
                "FoundationalFlow|Risk Classification"
              ),
              description: s_(
                "FoundationalFlow|Classify the risk of a merge request so review effort can be " \
                  "routed to the changes that warrant it."
              ),
              avatar: "gitlab-duo-flow.png",
              feature_maturity: "experimental",
              ai_feature: "duo_agent_platform",
              environment: "web",
              ultimate_only: true,
              feature_flag: "duo_mr_risk_classification",
              agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              suppress_agent_session_note: true,
              supported_resource_types: [::MergeRequest],
              triggers: [
                ::Ai::FlowTrigger::EVENT_TYPES[:merge_request],
                ::Ai::FlowTrigger::EVENT_TYPES[:merge_request_ready]
              ],
              additional_context_resolver: ->(resource:) do
                next {} unless resource.is_a?(::MergeRequest)

                domains = ::Gitlab::Duo::RiskClassification::Domain.all.map do |domain|
                  { "name" => domain.name, "description" => domain.description }
                end

                { CONTEXT_CATEGORY => { "domains" => domains } }
              end,
              before_start: ->(resource:) do
                next if resource.risk_assessment

                resource.create_risk_assessment!(diff_sha: resource.diff_head_sha)
              end
            }
          end
        end
      end
    end
  end
end
