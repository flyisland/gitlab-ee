# frozen_string_literal: true

module JH
  module Ai
    module Catalog
      module FoundationalFlow
        extend ActiveSupport::Concern

        JH_ADVANCED_CODE_REVIEW_FLOW_REFERENCE = 'jh_advanced_code_review/v1'

        class_methods do
          extend ::Gitlab::Utils::Override

          def jh_advanced_code_review_v1
            find_by(foundational_flow_reference: JH_ADVANCED_CODE_REVIEW_FLOW_REFERENCE)
          end

          override :fixed_items
          def fixed_items
            super + [
              {
                foundational_flow_reference: JH_ADVANCED_CODE_REVIEW_FLOW_REFERENCE,
                display_name: s_('JH|FoundationalFlow|JH Advanced Code Review'),
                description: s_(
                  'JH|FoundationalFlow|Review merge requests with related Issue and Pipeline context.'
                ),
                avatar: 'code-review-flow.png',
                feature_maturity: 'experimental',
                ai_feature: 'duo_agent_platform',
                agent_privileges: [
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
                ],
                suppress_mention_progress_note: true,
                triggers: [
                  ::Ai::FlowTrigger::EVENT_TYPES[:assign_reviewer],
                  ::Ai::FlowTrigger::EVENT_TYPES[:mention]
                ],
                goal_templates: ::JH::Ai::Catalog::GoalTemplates::JHAdvancedCodeReview
              }
            ]
          end
        end
      end
    end
  end
end
